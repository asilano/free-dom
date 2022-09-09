class GameUpdateChannel < Turbo::StreamsChannel
  def self.send_game_updates(game)
    game.users.each do |user|
      broadcast_replace_to(
        game,
        user,
        target: "game",
        partial: "game_board/game",
        object: game,
        locals: { viewer: user }
      )
    end

    broadcast_replace_to(
      game,
      nil,
      target: "game",
      partial: "game_board/game",
      object: game,
      locals: { viewer: nil }
    )
  end
end
