Feature: Wharf
  Now and at the start of your next turn: Draw 2 cards, +1 Buy.
  
  Background:
    Given I am a player in a standard game with Wharf
    
  Scenario: Wharf should be set up at game start
    Then there should be 10 Wharf cards in piles
      And there should be 0 Wharf cards not in piles
      
  Scenario: Playing Wharf
    Given my hand contains Wharf, Estate x4
      And my deck contains Estate x10
      And it is my Play Action phase
    When I play Wharf
      Then I should have drawn 2 cards
    When the game checks actions
      Then it should be my Buy phase
      And I should have 2 buys available
    When my next turn starts
    Then the following 2 steps should happen at once
      Then I should have moved Wharf from enduring to play
      And I should have drawn 2 cards
    And I should have 1 action available
    And I should have 2 buys available

  Scenario: Playing multiple Wharves
    Given my hand contains Wharf x2, Village, Estate x3
      And my deck contains Estate x10
      And it is my Play Action phase
    When I play Village
      Then I should have drawn 1 card
      And I should have 2 actions available
    When I play Wharf
      Then I should have drawn 2 cards
      And I should have 1 action available
    When I play Wharf
      Then I should have drawn 2 cards
      And I should have 0 actions available
    When the game checks actions
      Then it should be my Buy phase
      And I should have 3 buys available
    When my next turn starts
    Then the following 2 steps should happen at once
      Then I should have moved Wharf x2 from enduring to play
      And I should have drawn 4 cards
    And I should have 1 action available
    And I should have 3 buys available
    