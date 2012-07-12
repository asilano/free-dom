Feature: Smuggler
  Gain a copy of a card costing up to 6 Cash that the player to your right gained on his last turn.
  
  Background: Start in Charlie's turn letting him buy 0, 1 or 2 cards
    Given I am a player in a standard game with Smuggler
      And my hand contains Smuggler
      And Charlie's hand contains Woodcutter, Gold x3
      And it is Charlie's Play Action phase
    Then Charlie plays Woodcutter
      And the game checks actions
      Then Charlie should have played Gold x3
      And it should be Charlie's Buy phase
      And Charlie should have 2 buys available
      
  Scenario: Playing Smuggler - no valid options (only invalid option Province)
    When Charlie buys Province
      And the game checks actions
      Then Charlie should have gained Province
      And Charlie should have 1 buy available
    When Charlie stops buying cards
      And the game checks actions
      Then the following 2 steps should happen at once
      Then Charlie should have moved Woodcutter, Gold x3 from play to discard 
      And Charlie should have drawn 5 cards
    Then it should be my Play Action phase
    When I play Smuggler
      And the game checks actions
      Then it should be my Buy phase
      
  Scenario: Playing Smuggler - one valid option (Estate) plus invalid options (Province)
    When Charlie buys Province
      And the game checks actions
      Then Charlie should have gained Province
      And Charlie should have 1 buy available
    When Charlie buys Estate
      And the game checks actions
      Then the following 3 steps should happen at once
      And Charlie should have gained Estate
      And Charlie should have moved Woodcutter, Gold x3 from play to discard 
      And Charlie should have drawn 5 cards
    Then it should be my Play Action phase
    When I play Smuggler
      And the game checks actions
    Then I should have gained Estate
      And it should be my Buy phase
      
  Scenario: Playing Smuggler - multiple valid options (Gold, Estate)
    When Charlie buys Gold
      And the game checks actions
      Then Charlie should have gained Gold
      And Charlie should have 1 buy available
    When Charlie buys Estate
      And the game checks actions
      Then the following 3 steps should happen at once
      Then Charlie should have gained Estate
      And Charlie should have moved Woodcutter, Gold x3 from play to discard 
      And Charlie should have drawn 5 cards
    Then it should be my Play Action phase
    When I play Smuggler
      And the game checks actions
    Then I should need to Take a card with Smuggler
      And I should be able to choose the Estate, Gold piles
      And I should not be able to choose the Duchy, Province, Copper, Silver, Smuggler piles 
    When I choose the Gold pile
      And the game checks actions
    Then I should have gained Gold
      And it should be my Buy phase
    
    
  Scenario: Smuggler should be set up at game start
    Given I am a player in a standard game with Smuggler
    Then there should be 10 Smuggler cards in piles
      And there should be 0 Smuggler cards not in piles
      
      