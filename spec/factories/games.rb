FactoryBot.define do
  factory :game do
    name { "Test game" }
    discord_webhook { nil }
    created_at { Time.now }
  end

  factory :game_with_kingdom, parent: :game do
    after(:create) do |game|
      create(:kingdom_journal, game: game, user: create(:user, name: "Alan"))
    end
  end

  factory :game_with_one_player, parent: :game_with_kingdom do
    after(:create) do |game|
      create(:add_player_journal, game: game, user: game.users.first || create(:user, name: "Alan"))
    end
  end

  factory :game_with_two_players, parent: :game_with_one_player do
    after(:create) do |game|
      create(:add_player_journal, game: game, user: create(:user, name: "Belle"))
    end
  end

  factory :started_game_with_two_players, parent: :game_with_two_players do
    after(:create) do |game|
      create(:start_game_journal, game: game, user: game.users.first)
    end
  end
end
