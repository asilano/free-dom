Feature: Bridge
  +1 Buy, +1 Cash. All cards cost 1 less this turn, but not less than 0.
  
  Background:
    Given I am a player in a standard game with Bridge, Moat, Village, Smithy, Market, Adventurer, Forge
    
  Scenario: Bridge should be set up at game start
    Then there should be 10 Bridge cards in piles
      And there should be 0 Bridge cards not in piles
      
  Scenario: Playing Bridge
    Given my hand contains Bridge, Market, Copper, Estate x2
      And my deck contains Duchy
      And it is my Play Action phase
    When I play Market
    Then I should have drawn a card
      And I should have 1 cash
      And I should have 2 buys available
    When I play Bridge
    Then I should have 2 cash
      And I should have 3 buys available
      And the Copper pile should cost 0
      And the Moat pile should cost 1
      And the Village pile should cost 2
      And the Market pile should cost 4
    When the game checks actions
    Then I should have played Copper 
      And I should have 3 cash
      And I should need to Buy
      And I should be able to choose the Copper, Moat, Village, Bridge piles
      And I should not be able to choose the Market, Adventurer piles
    When I buy Moat
      And the game checks actions
    Then I should have gained Moat
    When I buy Village
      And the game checks actions
    Then I should have gained Village
    
  Scenario: Multiple Bridges
    Given my hand contains Village x2, Bridge x3
      And it is my Play Action phase
      And my deck contains Curse x2
    When I play Village
      Then I should have drawn 1 card
    And I play Village
      Then I should have drawn 1 card
      And I play Bridge
      And I play Bridge
      And I play Bridge
    Then I should have 3 cash
      And I should have 4 buys available
      And the Copper pile should cost 0
      And the Moat pile should cost 0
      And the Village pile should cost 0
      And the Smithy pile should cost 1
      And the Market pile should cost 2
    When the game checks actions
    Then I should have 3 cash
      And I should need to Buy
      And I should be able to choose the Copper, Moat, Village, Bridge, Market, Adventurer piles
      And I should not be able to choose the Forge pile