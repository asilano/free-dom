module GameEngine
  class AddPlayerJournal < Journal
    skip_owner_check

    def process(game_state)
      super
      game_state.players << GameEngine::PlayerState.new(user)
      @histories << History.new("#{user.name} joined the game.")
    end
  end
end