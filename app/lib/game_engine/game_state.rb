require 'fiber'

# GameState is the in-memory record of the game. It applies journals to itself,
# to update the game's state.
module GameEngine
  class UnexpectedJournalError < ArgumentError
  end
  class InvalidJournalError < ArgumentError
  end

  class GameState

    attr_reader :players, :piles, :cardlikes, :turn_player, :game, :artifacts, :phase, :trashed_cards
    attr_accessor :state, :rng, :fid_prefix, :next_fid, :last_active_player

    def initialize(seed, game)
      @seed = seed
      @game = game
      @scheduler = Scheduler.new

      @players = []
      @piles = []
      @cardlikes = []
      @trashed_cards = []
      @turn_player = nil
      @last_active_player = nil
      @phase = nil

      @artifacts = {}
      @facts = {enduring: {}, per_turn: {}}

      @next_fid = 0
      @fid_prefix = '1'
    end

    def run
      # Initialise
      @rng = Random.new(@seed)
      @state = :waiting
      Triggers::Trigger.clear_watchers

      # Ask the game creator what cards are in the Kingdom. We expect this to
      # proceed immediately, with a journal created with the game.
      get_journal(GameEngine::ChooseKingdomJournal, from: @players[0]).process(self)

      # Ask the game creator to start the game. The StartGameJournal template is
      # specially modified to allow the AddPlayerJournal to match it.
      until @state == :running
        get_journal(GameEngine::StartGameJournal, from: @players[0]).process(self)
      end

      turn_seat = 0
      round = 1
      loop do
        @phase = :action
        @turn_player = @players[turn_seat]
        @turn_player.actions = 1
        @turn_player.buys = 1
        @turn_player.cash = 0
        @facts[:per_turn] = {}

        @game.current_journal.histories << History.new("#{@turn_player.name} started turn #{round}.#{turn_seat + 1}.",
                                                       player: @turn_player)

        Triggers::StartOfTurn.trigger(@turn_player)

        # Play actions until the player stops or runs out
        play_actions = :continue
        until (@turn_player.actions.zero? && @turn_player.villagers.zero?) || play_actions == :stop
          play_actions = get_journal(GameEngine::PlayActionJournal, from: @turn_player).process(self)
          observe
        end

        @phase = :buy
        Triggers::StartOfBuyPhase.trigger(@turn_player)

        # Play treasures until the player stops or runs out
        play_treasures = :continue
        until play_treasures == :stop
          play_treasures = get_journal(GameEngine::PlayTreasuresJournal, from: @turn_player).process(self)
          observe
        end

        # Buy cards until the player stops our runs out of buys
        until @turn_player.buys.zero?
          get_journal(GameEngine::BuyCardJournal, from: @turn_player).process(self)
          observe
        end

        cleanup

        Triggers::EndOfTurn.trigger

        if game_ended?
          players.each(&:calculate_score)
          @game.current_journal.histories << History.new("Game ended.")
          players.sort_by(&:score).reverse.each_with_index do |ply, ix|
            @game.current_journal.histories << History.new("#{(ix + 1).ordinalize}: #{ply.name} with #{ply.score} points.",
                                                           player: ply)
          end
          return
        end

        turn_seat = (turn_seat + 1) % @players.length
        round += 1 if turn_seat.zero?
      end
    end

    def get_journal(journal_class, from:, revealed_cards: [], peeked_cards: [], opts: {})
      template = journal_class.from(from).in(@game).with(opts)

      journal = Fiber.yield(questions_to_ask(template, revealed_cards, peeked_cards))
      while journal.tag_along?
        journal.process(self)
        journal = Fiber.yield(questions_to_ask(template, revealed_cards, peeked_cards))
      end

      journal.question = template.question
      raise UnexpectedJournalError, "Unexpected journal type: #{journal.class}. Expecting: #{template.class.module_parent}" unless template.matches? journal
      raise InvalidJournalError, "Invalid journal: #{journal}" unless template.valid? journal

      @last_active_player = journal.player unless journal.auto
      journal
    end

    def player_for(user)
      @players.detect { |ply| ply.user == user }
    end

    def other_players(exclude_user:)
      @players.reject { |ply| ply.user == exclude_user }
    end

    def find_pile_by_top_card
      @piles.detect { |p| p.cards.present? && yield(p.cards.first) }
    end

    # Set up nested Fibers, one for each entry in forks, to handle the supplied block.
    # Present all the combined questions up to the caller.
    def in_parallel(forks, &block)
      # Unless there's only one fork, of course. Then fibering is unnecessary
      return if forks.empty?
      return forks.each(&block) if forks.length == 1

      sub_fibers = forks.map do |forker|
        FiberWrapper.new(self) { block.call(forker) }
      end

      questions = sub_fibers.map do |sub|
        q = sub.resume
        q if sub.alive?
      end
      while questions.any?
        # Get a journal for any of the questions, and post it into the
        # relevant fiber
        journal = Fiber.yield(questions)
        target = sub_fibers.detect { |sub| journal.fiber_id =~ /^#{sub.fid_prefix}(\.|$)/ }
        raise InvalidJournalError, "Incorrect fiber for journal: #{journal}" unless target

        new_q = target.resume(journal)
        questions[sub_fibers.index(target)] = target.alive? ? new_q : nil
      end
    end

    def next_fiber_id
      @next_fid += 1
    end

    def trigger(&block)
      @scheduler.trigger(&block)
    end

    def observe
      @scheduler.work
    end

    def create_artifact(klass)
      @artifacts[klass.to_s.demodulize] = klass.new(self)
    end

    def set_fact(name, value, duration: :per_turn)
      raise unless %i[enduring per_turn].include? duration
      @facts[duration][name] = value
    end

    def get_fact(name, duration: :per_turn)
      raise unless %i[enduring per_turn].include? duration
      @facts[duration][name]
    end

    def access_fact(name, duration: :per_turn)
      raise unless %i[enduring per_turn].include? duration
      define_singleton_method(name) { @facts[duration][name] }
    end

    def inspect
      "<GameSate:#{object_id}>"
    end

    private

    def cleanup
      @phase = :cleanup
      @game.current_journal.histories << History.new("#{@turn_player.name} ended their turn.",
                                                     player: @turn_player)

      Triggers::StartOfCleanup.trigger

      # Discard all hand cards
      @turn_player.hand_cards.each(&:discard)

      # Discard all non-tracking in-play cards
      @turn_player.played_cards.each { |c| c.played_this_turn = false }.reject(&:tracking?).each(&:discard)

      observe

      # # Draw a new hand
      cards_to_draw = 5
      cards_to_draw += 1 if @artifacts['Flag']&.owned_by?(@turn_player)
      @turn_player.draw_cards cards_to_draw

      observe
    end

    # Game ends if the Province pile (or Colony pile, if it exists), or
    # any three other piles, are empty.
    def game_ended?
      piles.detect { |p| p.card_class == BasicCards::Province }.cards.empty? ||
        # piles.detect { |p| p.card_class == Prosperity::Colony }.cards.empty? ||
        piles.count { |p| p.cards.empty? } >= 3
    end

    def questions_to_ask(template, revealed_cards, peeked_cards)
      qs = [template.question]
      if @phase == :action && @turn_player.villagers.positive?
        qs << SpendVillagersJournal.from(@turn_player).in(@game).question
      end
      if @phase == :buy && @turn_player.coffers.positive?
        qs << SpendCoffersJournal.from(@turn_player).in(@game).question
      end

      qs.each_with_index do |q, ix|
        q.fiber_id = @fid_prefix
        q.auto_candidate = template.player != @last_active_player
        (revealed_cards + peeked_cards).each { |c| c.interacting_with = q } if ix.zero?
      end
    end
  end

  class FiberWrapper
    attr_reader :fiber, :fiber_id, :next_fid, :fid_prefix, :rng
    delegate :alive?, to: :fiber

    def self.fibers_related(id_a, id_b)
      id_a == id_b ||
        id_a&.start_with?("#{id_b}.") ||
        id_b&.start_with?("#{id_a}.")
    end

    def initialize(game_state, &block)
      @game_state = game_state
      @next_fid = 0
      @fiber_id = game_state.next_fiber_id
      @fid_prefix = [game_state.fid_prefix, @fiber_id.to_s].join('.')
      @rng = Random.new("#{@game_state.rng.seed}#{@fid_prefix.gsub('.')}".to_i)
      @fiber = Fiber.new(&block)
    end

    def resume(*args)
      outer_rng = @game_state.rng
      @game_state.rng = @rng

      outer_next_fid = @game_state.next_fid
      @game_state.next_fid = @next_fid

      outer_fid_prefix = @game_state.fid_prefix
      @game_state.fid_prefix = @fid_prefix

      outer_last_active_player = @game_state.last_active_player

      result = @fiber.resume(*args)

      @game_state.last_active_player = outer_last_active_player
      @game_state.fid_prefix = outer_fid_prefix
      @game_state.next_fid = outer_next_fid
      @game_state.rng = outer_rng

      result
    end
  end
end
