#Games
  Factory.define :incomplete_game, :class => Game do |f|
    f.name "Game 1"
    f.max_players 3     
  end

  Factory.define :fixed_game, :parent => :incomplete_game do |f|
    f.random_select 0
    f.pile_1 "BaseGame::Adventurer"
    f.pile_2 "BaseGame::Mine"
    f.pile_3 "BaseGame::Moat"
    f.pile_4 "BaseGame::Thief"
    f.pile_5 "Seaside::Treasury"
    f.pile_6 "Seaside::Salvager"
    f.pile_7 "Intrigue::Nobles"
    f.pile_8 "Intrigue::Steward"
    f.pile_9 "Prosperity::TradeRoute"
    f.pile_10 "Prosperity::Rabble"
    f.plat_colony "no"
  end

  Factory.define :dist_random_game, :parent => :incomplete_game do |f|
    f.random_select 1
    f.specify_distr 1
    f.num_prosperity_cards 3
    f.num_base_game_cards 7
  end  

  Factory.define :full_random_game, :parent => :incomplete_game do |f|
    f.random_select 1
    f.specify_distr 0
    f.seaside_present 1
    f.intrigue_present 1
  end 

# Users
  Factory.define :user do |f|
    f.name "Alan"
    f.password "a"
    f.password_confirmation {|u| u.password}
    f.email {|u| "#{u.name}@example.com"}
  end
  
# Players
  Factory.define :player do end
  
# Pending Actions
  Factory.define :pending_action do |f|
    f.expected_action "action_which_is_expected"
  end
	
# Piles
  Factory.define :pile do |f|
    f.card_type "Intrigue::GreatHall"
  end		
  
# Rankings
  Factory.define :ranking do |f|
    f.num_played            5
    f.num_won               2
    f.total_normalised_pos  1.25
    f.total_score           149
    f.result_elo            1620
    f.score_elo             1630    
    
    f.last_num_won         1
    f.last_total_norm_pos  1.25
    f.last_total_score     119
    f.last_result_elo      1615
    f.last_score_elo       1620
  end