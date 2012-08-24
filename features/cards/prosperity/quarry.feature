Feature: Quarry
  1 Cash. While this is in play, Action cards cost 2 less, but not less than 0.
  
  Background:
    Given I am a player in a standard game with Quarry, Moat, Fishing Village, Smithy, Market, Nobles, Harem, Forge
    
  Scenario: Quarry should be set up at game start
    Then there should be 10 Quarry cards in piles
      And there should be 0 Quarry cards not in piles
      
  Scenario: Playing Quarry
    Given my hand contains Quarry
      And it is my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then I should have played Quarry 
      And I should have 1 cash
      And I should need to Buy
      And the Silver pile should cost 3
      And the Duchy pile should cost 5
      And the Moat pile should cost 0
      And the Fishing Village pile should cost 1
      And the Smithy pile should cost 2
      And the Market pile should cost 3
      And the Nobles pile should cost 4
      And the Harem pile should cost 6
      And the Forge pile should cost 5    
    
  Scenario: Multiple Quarry
    Given my hand contains Quarry x2
      And it is my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then I should have played Quarry x2 
      And I should have 2 cash
      And I should need to Buy
      And the Silver pile should cost 3
      And the Duchy pile should cost 5
      And the Moat pile should cost 0
      And the Fishing Village pile should cost 0
      And the Smithy pile should cost 0
      And the Market pile should cost 1
      And the Nobles pile should cost 2
      And the Harem pile should cost 6
      And the Forge pile should cost 3