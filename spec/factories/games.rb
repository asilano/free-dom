FactoryBot.define do
  factory :game do
    name { "Test game" }
  end

  factory :game_with_kingdom, parent: :game do
    after(:create) do |game|
      create(:kingdom_journal, game: game)
    end
  end

  factory :game_with_two_players, parent: :game_with_kingdom do
    after(:create) do |game|
      create(:add_player_journal, game: game)
      create(:add_player_journal, game: game)
    end
  end
end
