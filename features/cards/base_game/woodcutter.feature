Feature: Woodcutter
  +1 Buy, +2 Cash
    
  Background:
    Given I am a player in a standard game with Woodcutter
  
  Scenario: Woodcutter should be set up at game start
    Then there should be 10 Woodcutter cards in piles
      And there should be 0 Woodcutter cards not in piles
  
  Scenario: Playing Woodcutter
    Given my hand contains Woodcutter and 4 other cards
      And it is my Play Action phase
    When I play Woodcutter
    Then I should have 2 buys available
      And I should have 2 cash
      And it should be my Play Treasure phase
      
  Scenario: Playing multiple Woodcutters
    Given my hand contains Village, Woodcutter, Woodcutter and 4 other cards
      And it is my Play Action phase
    When I play Village
    Then I should have drawn 1 card
    When I play Woodcutter
    Then I should have 2 buys available
      And I should have 2 cash
      And it should be my Play Action phase
    When I play Woodcutter
    Then I should have 3 buys available
      And I should have 4 cash
      And it should be my Play Treasure phase
      
