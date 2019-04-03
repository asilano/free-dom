class GameEngine::StartGameJournal < Journal
  define_question do |game_state|
    qn = 'Wait for more players'
    if game_state.players.length > 1
      qn << ' or Start the game'
    end
    qn
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

