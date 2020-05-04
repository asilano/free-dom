require 'fiber'

# GameState is the in-memory record of the game. It applies journals to itself,
# to update the game's state.
module GameEngine
  class GameState
    class UnexpectedJournalError < ArgumentError
    end
    class InvalidJournalError < ArgumentError
    end

    attr_reader :players, :piles, :turn_player, :game
    attr_accessor :state, :rng, :fid_prefix, :next_fid, :last_active_player

    def initialize(seed, game)
      @seed = seed
      @game = game

      @players = []
      @piles = []
      @turn_player = nil
      @last_active_player = nil

      @next_fid = 0
      @fid_prefix = '1'
    end

    def run
      # Initialise
      @rng = Random.new(@seed)
      @state = :waiting

      # Ask the game creator what cards are in the Kingdom. We expect this to
      # proceed immediately, with a journal created with the game.
      get_journal(GameEngine::ChooseKingdomJournal, from: @players[0]).process(self)

      # Ask the game creator to start the game. The StartGameJournal template is
      # specially modified to allow the AddPlayerJournal to match it.
      until @state == :running
        get_journal(GameEngine::StartGameJournal, from: @players[0]).process(self)
      end

      turn_seat = 0
      loop do
        @turn_player = @players[turn_seat]
        @turn_player.actions = 1
        @turn_player.buys = 1
        @turn_player.cash = 0

        # Play actions until the player stops or runs out
        until @turn_player.actions.zero?
          get_journal(GameEngine::PlayActionJournal, from: @turn_player).process(self)
        end

        # Play treasures until the player stops or runs out
        play_treasures = :continue
        until play_treasures == :stop
          play_treasures = get_journal(GameEngine::PlayTreasuresJournal, from: @turn_player).process(self)
        end

        # Buy cards until the player stops our runs out of buys
        until @turn_player.buys.zero?
          get_journal(GameEngine::BuyCardJournal, from: @turn_player).process(self)
        end

        cleanup

        turn_seat = (turn_seat + 1) % @players.length
      end
    end

    def get_journal(journal_class, from:, revealed_cards: nil, opts: {})
      template = journal_class.from(from).in(@game).with(opts)
      journal = Fiber.yield(template.question.tap do |q|
        q.fiber_id = @fid_prefix
        q.auto_candidate = from != @last_active_player
        if revealed_cards
          q.revealed_cards = revealed_cards
          revealed_cards.each { |c| c.interacting_with = q }
        end
      end)
      while journal.is_a? GameEngine::HackJournal
        journal.process(self)
        journal = Fiber.yield(template.question)
      end
      raise UnexpectedJournalError, "Unexpected journal type: #{journal.class}. Expecting: #{template.class.parent}" unless template.matches? journal
      raise InvalidJournalError, "Invalid journal: #{journal}" unless template.valid? journal

      @last_active_player = journal.player unless journal.auto
      journal.tap { |j| j.question = template.question }
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
        sub.resume
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

    private

    def cleanup
      @game.current_journal.histories << History.new("#{@turn_player.name} ended their turn.",
                                                     player: @turn_player)

      # Discard all hand cards
      @turn_player.hand_cards.each(&:discard)

      # Discard all non-tracking in-play cards
      @turn_player.played_cards.reject(&:tracking?).each(&:discard)

      # # Draw a new hand
      @turn_player.draw_cards 5
    end
  end

  class FiberWrapper
    attr_reader :fiber, :fiber_id, :next_fid, :fid_prefix, :rng
    delegate :alive?, to: :fiber

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
