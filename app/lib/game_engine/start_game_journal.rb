class GameEngine::StartGameJournal < Journal
  define_question do |game_state|
    qn = 'Wait for more players'
    if game_state.players.length > 1
      qn << ' or Start the game'
    end
    qn
  end.with_controls do
    [ButtonControl.new(player: @player,
                       scope: :player,
                       values: [['Start the game', 'start']])]
  end

  def process(game_state)
    super
    game_state.state = :running
  end

  class Template
    def matches?(journal)
      return true if super
      return false unless journal.is_a? GameEngine::AddPlayerJournal
      define_singleton_method(:journal) { journal }
      valid? journal
    end
  end
end

