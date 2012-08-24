Feature: Pawn
  Choose two: Draw 1 card; +1 Action; +1 Buy; +1 Cash.
    
  Background:
    Given I am a player in a standard game with Pawn
  
  Scenario: Pawn should be set up at game start
    Then there should be 10 Pawn cards in piles
      And there should be 0 Pawn cards not in piles
      
  Scenario: Playing Pawn - card and action
    Given my hand contains Pawn and 4 other cards
      And it is my Play Action phase
    When I play Pawn
    Then I should need to Choose two, with Pawn
    When I choose the options Draw 1, +1 Action
    Then I should have drawn 1 card
      And I should have 1 action available
      And it should be my Play Action phase
      
  Scenario: Playing Pawn - card and buy
    Given my hand contains Pawn and 4 other cards
      And it is my Play Action phase
    When I play Pawn
    Then I should need to Choose two, with Pawn
    When I choose the options Draw 1, +1 Buy
    Then I should have drawn 1 card
      And I should have 2 buys available
      And it should be my Play Treasure phase
      
  Scenario: Playing Pawn - card and cash
    Given my hand contains Pawn and 4 other cards
      And it is my Play Action phase
    When I play Pawn
    Then I should need to Choose two, with Pawn
    When I choose the options Draw 1, +1 Cash
    Then I should have drawn 1 card
      And I should have 1 cash
      And it should be my Play Treasure phase
      
  Scenario: Playing Pawn - action and buy
    Given my hand contains Pawn and 4 other cards
      And it is my Play Action phase
    When I play Pawn
    Then I should need to Choose two, with Pawn
    When I choose the options +1 Action, +1 Buy
    Then I should have 1 action available
      And I should have 2 buys available
      And it should be my Play Action phase
      
  Scenario: Playing Pawn - action and cash
    Given my hand contains Pawn and 4 other cards
      And it is my Play Action phase
    When I play Pawn
    Then I should need to Choose two, with Pawn
    When I choose the options +1 Action, +1 Cash
    Then I should have 1 action available
      And I should have 1 cash
      And it should be my Play Action phase
      
  Scenario: Playing Pawn - buy and cash
    Given my hand contains Pawn and 4 other cards
      And it is my Play Action phase
    When I play Pawn
    Then I should need to Choose two, with Pawn
    When I choose the options +1 Buy, +1 Cash
    Then I should have 2 buys available
      And I should have 1 cash
      And it should be my Play Treasure phase
      
  Scenario: Playing Pawn - bad choices
    Given my hand contains Pawn and 4 other cards
      And it is my Play Action phase
    When I play Pawn
    Then I should need to Choose two, with Pawn
    When I choose the options Draw 1, +1 Action, +1 Buy
    Then I should need to Choose two, with Pawn
    When I choose the options Draw 1
    Then I should need to Choose two, with Pawn