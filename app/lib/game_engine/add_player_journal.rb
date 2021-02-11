module GameEngine
  class AddPlayerJournal < Journal
    after_create :force_discord_log

    skip_owner_check

    process do |game_state|
      game_state.players << PlayerState.new(user, game_state)
      @histories << History.new("#{user.name} joined the game.")
    end

    private

    def force_discord_log
      # Force the game to log this journal to discord
      game.update(last_notified_players: [])
    end
  end
end
