require 'discordrb/webhooks'

class Game < ApplicationRecord
  has_many :journals, -> { order(:order).extending(PersistedExtension) }, dependent: :destroy, inverse_of: :game
  has_many :users, -> { unscope(:order).distinct }, through: :journals

  accepts_nested_attributes_for :journals

  attr_reader :game_state, :questions, :last_fixed_journal_order, :current_journal, :run_state

  # Execute the game's journals in memory.
  def process
    # Initialise things
    @last_fixed_journal_order = 0
    @run_state = journals.where(type: 'GameEngine::StartGameJournal').blank? ? :waiting : :running
    @journal_stack = []

    # Spawn a GameState object, seeding it with our creating time
    # in nanoseconds
    @game_state = GameEngine::GameState.new(created_at.nsec, self)

    # Prepare a Fiber to run the game state in a coroutiney way
    fiber = Fiber.new { @game_state.run }

    # Kick the fiber off, and wait for the first question
    @questions = *fiber.resume

    # Until we run out of answers, post journals in as answers to questions
    journals.each do |j|
      # Allow tests to ignore individual journals
      next if j.ignore
      @questions = *fiber.resume(j)

      unless fiber.alive?
        @run_state = :ended
        return
      end

      @questions.compact!
    rescue => e
      @questions = []
      return
    end

    # Before going back to the users, see if the question:
    # * was caused by someone other than the person who needs to answer; and
    # * has only one valid choice
    # In that case, we synthesise the journal and carry on.
    # Buuut, we have to keep a hold of who the last _active_ person is, in case
    # there's a follow-up no-choice for the same player.
    while @questions.any? { |q| q.auto_candidate && q.can_be_auto_answered?(@game_state) }
      auto_journal = @questions.lazy.map { |q| q.auto_answer(@game_state) }.detect(&:itself)
      auto_journal.auto = true
      @questions = *fiber.resume(auto_journal)
      @questions.compact!
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
    journal = @current_journal #@journal_stack.last if journal == :current
    journal ||= journals.last
    @last_fixed_journal_order = journal.order
  end

  def last_fixed_journal_for(user)
    journals.where('journals.order <= ?', @last_fixed_journal_order).or(journals.where.not(user: user)).last
  end

  def controls_for(user)
    @questions.flat_map { |q| q&.controls_for(user, @game_state) }.compact
  end

  def notify_discord
    return if discord_webhook.blank?

    to_act = @questions.map { |q| q.player.user }
    to_act_ids = to_act.map(&:id).sort
    return if to_act_ids == last_notified_players

    update(last_notified_players: to_act_ids)
    client = Discordrb::Webhooks::Client.new(url: discord_webhook)
    client.execute do |builder|
      builder.content = "#{to_act.map(&:discord_mention).join(', ')} to act."
      builder.username = 'FreeDom Server'
    end
  end
end
