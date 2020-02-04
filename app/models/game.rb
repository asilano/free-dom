class Game < ApplicationRecord
  has_many :journals, -> { order(:order).extending(PersistedExtension) }, dependent: :destroy, inverse_of: :game
  has_many :users, -> { unscope(:order).distinct }, through: :journals

  accepts_nested_attributes_for :journals

  attr_reader :game_state, :question, :last_fixed_journal_order, :current_journal

  # Execute the game's journals in memory.
  def process
    # Initialise things
    @last_fixed_journal_order = 0
    @journal_stack = []

    # Spawn a GameState object, seeding it with our creating time
    # in nanoseconds
    @game_state = GameEngine::GameState.new(created_at.nsec, self)

    # Prepare a Fiber to run the game state in a coroutiney way
    fiber = Fiber.new { @game_state.run }

    # Kick the fiber off, and wait for the first question
    @question = fiber.resume

    # Until we run out of answers, post journals in as answers to questions
    journals.each do |j|
      # Allow tests to ignore individual journals
      next if j.ignore
      @question = fiber.resume(j)
    end

    # Before going back to the users, see if the question:
    # * was caused by someone other than the person who needs to answer; and
    # * has only one valid choice
    # In that case, we synthesise the journal and carry on.
    # Buuut, we have to keep a hold of who the last _active_ person is, in case
    # there's a follow-up no-choice for the same player.
    spawner = journals.last&.player
    while @question.can_be_auto_answered?(@game_state, spawner: spawner)
      auto_journal = @question.auto_answer(@game_state)
      @question = fiber.resume(auto_journal)
    end
  end

  def push_journal(journal)
    @journal_stack.push journal
    @current_journal = journal
  end

  def pop_journal
    journal = @journal_stack.pop
    @current_journal = journal unless journal.nil?
    journal
  end

  # Mark a journal as not able to be undone
  def fix_journal(journal: :current)
    journal = @journal_stack.last if journal == :current
    @last_fixed_journal_order = journal.order
  end

  def last_fixed_journal_for(user)
    journals.where('journals.order <= ?', @last_fixed_journal_order).or(journals.where.not(user: user)).last
  end
end
