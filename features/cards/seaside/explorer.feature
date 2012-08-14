Feature: Explorer
  You may reveal a Province card from your hand. If you do, gain a Gold card, putting it into your hand. Otherwise, gain a Silver card, putting it into your hand.
    
  Background:
    Given I am a player in a standard game with Explorer, Grand Market
    # Grand Market to hold up autoplay of treasures
  
  Scenario: Explorer should be set up at game start
    Then there should be 10 Explorer cards in piles
      And there should be 0 Explorer cards not in piles
  
  Scenario: Playing Explorer with no Province in hand
    Given my hand contains Explorer, Estate, Duchy, Colony, Gold
      And it is my Play Action phase
    When I play Explorer
      Then I should need to Choose a province to reveal
    When I choose Choose no Province in my hand
      And the game checks actions
      Then I should have gained Silver to my hand
      And it should be my Play Treasure phase
      
  Scenario Outline: Playing Explorer with Provinces in hand
    Given my hand contains Explorer, <rest of hand>
      And it is my Play Action phase
    When I play Explorer
      Then I should need to Choose a province to reveal
    When I choose <choice> in my hand
      And the game checks actions
      Then I should have gained <gain> to my hand
      And it should be my Play Treasure phase
      
    Examples:
      | rest of hand                       |       choice       |  gain  |
      | Province, Estate, Duchy, Colony    |      Province      |  Gold  |
      | Province, Estate, Duchy, Colony    | Choose no Province | Silver |
      | Province, Province, Province, Gold |      Province      |  Gold  |
      | Province, Province, Province, Gold | Choose no Province | Silver |
      