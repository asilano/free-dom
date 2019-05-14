# GameState is the in-memory record of the game. It applies journals to itself,
# to update the game's state.
class GameEngine::GameState
  class UnexpectedJournalError < ArgumentError
  end
  class InvalidJournalError < ArgumentError
  end

  attr_reader :logs, :players, :piles
  attr_accessor :state

  def initialize(seed)
    @seed = seed

    @players = []
    @piles = []
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

    loop do
      turn_player = @players[0]
      get_journal(GameEngine::PlayActionJournal, from: turn_player).process(self)
    end
  end

  def get_journal(journal_class, from:, opts: {})
    template = journal_class.from(from).with(opts)
    journal = Fiber.yield(template.question)
    raise UnexpectedJournalError, "Unexpected journal type: #{journal}" unless template.matches? journal
    raise InvalidJournalError, "Invalid journal: #{journal}" unless template.valid? journal
    journal
  end

  def other_players(exclude_user:)
    @players.reject { |ply| ply.user == exclude_user }
  end
end