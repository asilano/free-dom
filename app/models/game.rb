require 'discordrb/webhooks'

class Game < ApplicationRecord
  has_many :journals, -> { order(:order).extending(PersistedExtension) }, dependent: :destroy, inverse_of: :game
  has_many :users, -> { unscope(:order).distinct }, through: :journals

  accepts_nested_attributes_for :journals

  attr_reader :game_state, :questions, :fiber_last_fixed_journal_orders, :current_journal, :run_state

  # Execute the game's journals in memory.
  def process
    # Initialise things
    @fiber_last_fixed_journal_orders = {}
    @run_state = journals.where(type: 'GameEngine::StartGameJournal').blank? ? :waiting : :running
    @journal_stack = []

    # Spawn a GameState object, seeding it with our creating time
    # in nanoseconds
    @game_state = GameEngine::GameState.new(created_at.nsec, self)

    # Prepare a Fiber to run the game state in a coroutiney way
    fiber = Fiber.new { @game_state.run }

    # Kick the fiber off, and wait for the first question
    @questions = Array(fiber.resume).flatten

    # Until we run out of answers, post journals in as answers to questions
    journals.each do |j|
      # Allow tests to ignore individual journals
      next if j.ignore
      @questions = Array(fiber.resume(j)).flatten

      unless fiber.alive?
        @run_state = :ended
        return
      end

      @questions.compact!
    rescue => e
      raise
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
      @questions = Array(fiber.resume(auto_journal)).flatten
      @questions.compact!
    end
  end

  def push_journal(journal)
    @journal_stack.push journal
    @current_journal = journal
  end

  def pop_journal
    journal = @journal_stack.pop
    # @current_journal = journal unless journal.nil?
    # journal
  end

  # Mark a journal as not able to be undone
  def fix_journal(journal: :current)
    journal = @current_journal if journal == :current
    journal ||= journals.last
    @fiber_last_fixed_journal_orders[journal.fiber_id] = journal.order
  end

  def controls_for(user)
    @questions.flat_map { |q| q&.controls_for(user, @game_state) }.compact
  end

  def notify_discord
    return if discord_webhook.blank?
    return if (to_act_ids = users_to_act.map(&:id).sort) == last_notified_players

    send_discord_log
    sleep 1
    send_discord_notify_players if to_act_ids.present?

    update(last_notified_players: to_act_ids, last_notified_journal: journals.maximum(:id))
  end

  def discord_log_creation
    send_msg_to_discord "Game #{name} (##{id}) created."
  end

  def inspect
    "<Game id: #{id}, name: #{name}>"
  end

  private

  def users_to_act
    @questions.map { |q| q.player.user }.uniq
  end

  def send_discord_log
    journals.each.select { |j| j.id > (last_notified_journal || 0) }.each do |j|
      log = j.format_for_discord
      send_msg_to_discord log if log
      sleep 1
    end
  end

  def send_discord_notify_players
    send_msg_to_discord "#{users_to_act.map(&:discord_mention).join(', ')} to act."
  end

  def send_msg_to_discord(msg)
    return if discord_webhook.blank?

    client = Discordrb::Webhooks::Client.new(url: discord_webhook)
    client.execute do |builder|
      builder.content = msg
      builder.username = 'FreeDom Server'
      builder.avatar_url = Rails.application.routes.url_helpers.root_url + 'discord-avatar.png'
    end
  end
end
