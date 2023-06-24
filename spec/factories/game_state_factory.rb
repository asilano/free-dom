FactoryBot.define do
  factory :game_state, class: GameEngine::GameState do
    game
    seed { 123456 }

    initialize_with { new(seed, game) }
  end
end
