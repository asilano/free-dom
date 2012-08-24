Feature: Workers' Village
  Draw 1 card, +2 Actions, +1 Buy
    
  Background:
    Given I am a player in a standard game with Workers' Village
  
  Scenario: Workers' Village should be set up at game start
    Then there should be 10 Workers' Village cards in piles
      And there should be 0 Workers' Village cards not in piles
  
  Scenario: Playing Workers' Village
    Given my hand contains Workers' Village and 4 other cards
      And it is my Play Action phase
    When I play Workers' Village
      Then I should have drawn 1 card
      And I should have 2 actions available
      And I should have 2 buys available
      And it should be my Play Action phase
      
  Scenario: Playing multiple Workers' Villages
    Given my hand contains Workers' Village, Workers' Village and 4 other cards
      And it is my Play Action phase
    When I play Workers' Village
      Then I should have drawn 1 card
      And I should have 2 actions available
      And I should have 2 buys available 
      And it should be my Play Action phase
    When I play Workers' Village
      Then I should have drawn 1 card
      And I should have 3 actions available
      And I should have 3 buys available
      And it should be my Play Action phase
      
