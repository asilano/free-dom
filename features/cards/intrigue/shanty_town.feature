Feature: Shanty Town
  +2 Actions. Reveal your hand. If you have no Action cards in hand, draw 2 cards
    
  Background:
    Given I am a player in a standard game with Shanty Town
  
  Scenario: Shanty Town should be set up at game start
    Then there should be 10 Shanty Town cards in piles
      And there should be 0 Shanty Town cards not in piles
  
  Scenario: Playing Shanty Town - no actions
    Given my hand contains Shanty Town, Duchy x4
      And it is my Play Action phase
    When I play Shanty Town
    Then I should have drawn 2 cards
      And I should have 2 actions available
      And it should be my Play Action phase
      
  Scenario: Playing Shanty Town - actions
    Given my hand contains Shanty Town, Smithy, Witch, Duchy x2
      And it is my Play Action phase
    When I play Shanty Town
    Then I should have 2 actions available
      And it should be my Play Action phase