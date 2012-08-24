Feature: Festival
  +2 Actions, +1 Buy, +2 Cash
    
  Background:
    Given I am a player in a standard game with Festival
  
  Scenario: Festival should be set up at game start
    Then there should be 10 Festival cards in piles
      And there should be 0 Festival cards not in piles
  
  Scenario: Playing Festival
    Given my hand contains Festival and 4 other cards
      And it is my Play Action phase
    When I play Festival
    Then I should have 2 actions available
      And I should have 2 buys available
      And I should have 2 cash
      
  Scenario: Playing multiple Festivals
    Given my hand contains Festival, Festival and 4 other cards
      And it is my Play Action phase
    When I play Festival
    Then I should have 2 actions available
      And I should have 2 buys available
      And I should have 2 cash
    When I play Festival
    Then I should have 3 actions available
      And I should have 3 buys available
      And I should have 4 cash