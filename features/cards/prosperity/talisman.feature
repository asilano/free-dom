Feature: Talisman
  1 Cash. 
    While this is in play, when you buy a card costing 4 or less that is not a Victory card, gain a copy of it.
  
  Background:
    Given I am a player in a standard game with Talisman, Moat, Village, Scout, Mine, Island
    
  Scenario: Talisman should be set up at game start
    Then there should be 10 Talisman cards in piles
      And there should be 0 Talisman cards not in piles
      
  Scenario Outline: Talisman, qualifying cards
    Given my hand contains Woodcutter, Talisman, Gold x2
      And it is my Play Action phase    
    When I play Woodcutter
      And the game checks actions
    Then I should have played Talisman, Gold x2
      And it should be my Buy phase
      And I should have 9 cash
    When I buy <card>
      And the game checks actions
    Then I should have gained <card> x2
      And it should be my Buy phase          
    
  Examples:
  | card    |
  | Copper  |
  | Silver  |
  | Moat    |
  | Village |
  | Scout   |
  
  Scenario Outline: Talisman, non-qualifying cards
    Given my hand contains Woodcutter, Talisman, Gold x2
      And it is my Play Action phase    
    When I play Woodcutter
      And the game checks actions
    Then I should have played Talisman, Gold x2
      And it should be my Buy phase
      And I should have 9 cash
    When I buy <card>
      And the game checks actions
    Then I should have gained <card>
      And it should be my Buy phase          
    
  Examples:
  | card   |
  | Gold   |
  | Mine   |
  | Island |
  
  Scenario Outline: Talisman, multiple copies
    Given my hand contains Woodcutter, Talisman x3, Gold x2
      And it is my Play Action phase    
    When I play Woodcutter
      And the game checks actions
    Then I should have played Talisman x3, Gold x2
      And it should be my Buy phase
      And I should have 11 cash
    When I buy <card>
      And the game checks actions
    Then I should have gained <card> x4
      And it should be my Buy phase          
    
  Examples:
  | card    |
  | Copper  |
  | Silver  |
  | Moat    |
  | Village |
  | Scout   |