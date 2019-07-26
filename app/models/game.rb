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
    journals.each { |j| @question = fiber.resume(j) }
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
