FactoryGirl.define do
  #Games
  factory :game do end
  factory :incomplete_game, :parent => :game do
    name "Game 1"
    max_players 3
  end

  factory :fixed_game, :parent => :incomplete_game do
    random_select 0
    pile_1 "BaseGame::Adventurer" # cost: 6
    pile_2 "BaseGame::Mine"       # cost: 5
    pile_3 "BaseGame::Moat"       # cost: 2
    pile_4 "BaseGame::Thief"      # cost: 4
    pile_5 "Seaside::Treasury"    # cost: 5
    pile_6 "Seaside::Salvager"    # cost: 4
    pile_7 "Intrigue::Nobles"     # cost: 6
    pile_8 "Intrigue::Steward"    # cost: 3
    pile_9 "Prosperity::TradeRoute" #cost: 3
    pile_10 "Prosperity::Rabble"  # cost: 5
    plat_colony "no"
  end

  factory :dist_random_game, :parent => :incomplete_game do
    random_select 1
    specify_distr 1
    num_prosperity_cards 3
    num_base_game_cards 7
  end

  factory :full_random_game, :parent => :incomplete_game do
    random_select 1
    specify_distr 0
    seaside_present 1
    intrigue_present 1
  end

  # Users
  factory :user do
    name "Alan"
    password "a"
    password_confirmation {|u| u.password}
    email {|u| "#{u.name}@example.com"}
  end

  # Players
  factory :player do
    association :user
    association :game
  end

  # Rankings
  factory :ranking do
    num_played            5
    num_won               2
    total_normalised_pos  1.25
    total_score           149
    result_elo            1620
    score_elo             1630

    last_num_won         1
    last_total_norm_pos  1.25
    last_total_score     119
    last_result_elo      1615
    last_score_elo       1620
  end
end