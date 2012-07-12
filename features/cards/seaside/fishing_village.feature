Feature: Fishing Village
  +2 Actions, +1 Cash. 
  At the start of your next turn: +1 Action, +1 Cash.
  
  Background:
    Given I am a player in a standard game with Fishing Village
    
  Scenario: Fishing Village should be set up at game start
    Then there should be 10 Fishing Village cards in piles
      And there should be 0 Fishing Village cards not in piles
      
  Scenario: Playing Fishing Village
    Given my hand contains Fishing Village and 4 other cards
      And it is my Play Action phase
    When I play Fishing Village
    Then I should have 1 cash
      And I should have 2 actions available
    When my next turn starts
    Then I should have moved Fishing Village from enduring to play
      And I should have 1 cash
      And I should have 2 actions available
      
  Scenario: Playing multiple Fishing Villages
    Given my hand contains Fishing Village x2 and 3 other cards
      And it is my Play Action phase
    When I play Fishing Village
    Then I should have 1 cash
      And I should have 2 actions available
      And I should have 4 cards in hand
    When I play Fishing Village
    Then I should have 2 cash
      And I should have 3 actions available
      And I should have 3 cards in hand
    When my next turn starts
    Then I should have moved Fishing Village x2 from enduring to play
      And I should have 2 cash
      And I should have 3 actions available