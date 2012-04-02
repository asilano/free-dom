FactoryGirl.define do
  #Games
  factory :game do end
  factory :incomplete_game, :parent => :game do 
    name "Game 1"
    max_players 3     
  end

  factory :fixed_game, :parent => :incomplete_game do
    random_select 0
    pile_1 "BaseGame::Adventurer"
    pile_2 "BaseGame::Mine"
    pile_3 "BaseGame::Moat"
    pile_4 "BaseGame::Thief"
    pile_5 "Seaside::Treasury"
    pile_6 "Seaside::Salvager"
    pile_7 "Intrigue::Nobles"
    pile_8 "Intrigue::Steward"
    pile_9 "Prosperity::TradeRoute"
    pile_10 "Prosperity::Rabble"
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
  
  # Pending Actions
  factory :pending_action do
    expected_action "action_which_is_expected"
  end
	
  # Piles
  factory :pile do
    card_type "Intrigue::GreatHall"
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