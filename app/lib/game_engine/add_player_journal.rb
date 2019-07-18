module GameEngine
  class AddPlayerJournal < Journal
    skip_owner_check

    process do |game_state|
      game_state.players << GameEngine::PlayerState.new(user)
      @histories << History.new("#{user.name} joined the game.")
    end
  end
end