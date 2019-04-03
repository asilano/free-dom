class GameEngine::AddPlayerJournal < Journal
  def process(game_state)
    game_state.players << GameEngine::PlayerState.new(user)
    game_state.logs << "#{user.name} joined the game."
  end
end