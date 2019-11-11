# GameState is the in-memory record of the game. It applies journals to itself,
# to update the game's state.
module GameEngine
  class GameState
    class UnexpectedJournalError < ArgumentError
    end
    class InvalidJournalError < ArgumentError
    end

    attr_reader :logs, :players, :piles, :turn_player, :game
    attr_accessor :state

    def initialize(seed, game)
      @seed = seed
      @game = game

      @players = []
      @piles = []
      @turn_player = nil

      # TODO: Temporary debug output
      @logs = []
    end

    def run
      # Initialise
      srand(@seed)
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

    def get_journal(journal_class, from:, opts: {})
      template = journal_class.from(from).with(opts)
      journal = Fiber.yield(template.question)
      while journal.is_a? GameEngine::HackJournal
        journal.process(self)
        journal = Fiber.yield(template.question)
      end
      raise UnexpectedJournalError, "Unexpected journal type: #{journal.class}. Expecting: #{template.class::Parent}" unless template.matches? journal
      raise InvalidJournalError, "Invalid journal: #{journal}" unless template.valid? journal
      journal
    end

    def player_for(user)
      @players.detect { |ply| ply.user == user }
    end

    def other_players(exclude_user:)
      @players.reject { |ply| ply.user == exclude_user }
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
end
