# GameState is the in-memory record of the game. It applies journals to itself,
# to update the game's state.
class GameEngine::GameState
  class UnexpectedJournalError < ArgumentError
  end
  class InvalidJournalError < ArgumentError
  end

  attr_reader :logs, :players, :piles

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
    get_journal(GameEngine::ChooseKingdomJournal).process(self)

    # Ask the game creator to start the game. The StartGameJournal template is
    # specially modified to allow the AddPlayerJournal to match it.
    until @state == :running do
      get_journal(GameEngine::StartGameJournal).process(self)
    end

    loop do
      journal = Fiber.yield('Question here')
    end
  end

  def get_journal(journal_class, opts = {})
    journal = Fiber.yield(journal_class.with(opts).question)
    raise UnexpectedJournalError, "Unexpected journal type: #{journal}" unless journal_class.with(opts).matches? journal
    raise InvalidJournalError, "Invalid journal: #{journal}" unless journal_class.with(opts).valid? journal
    journal
  end
end