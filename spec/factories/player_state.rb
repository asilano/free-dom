FactoryBot.define do
  factory :player_state, class: GameEngine::PlayerState do
    game_state
    user

    initialize_with { new(user, game_state) }
  end
end
