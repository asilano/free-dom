Feature: Laboratory
  +1 Actions, +2 Cards
    
  Background:
    Given I am a player in a standard game with Laboratory
  
  Scenario: Laboratory should be set up at game start
    Then there should be 10 Laboratory cards in piles
      And there should be 0 Laboratory cards not in piles
  
  Scenario: Playing Laboratory
    Given my hand contains Laboratory and 4 other cards
      And it is my Play Action phase
    When I play Laboratory
    Then I should have drawn 2 cards
      And I should have 1 action available
      And it should be my Play Action phase