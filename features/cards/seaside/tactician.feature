Feature: Tactician
  Discard your hand. If you discarded any cards this way, then at the start of your next turn, Draw 5 cards, +1 Buy, and +1 Action.

  Background:
    Given I am a player in a standard game with Tactician

  Scenario: Tactician should be set up at game start
    Then there should be 10 Tactician cards in piles
      And there should be 0 Tactician cards not in piles

  Scenario: Playing Tactician 
    Given my hand contains Tactician, Copper x2, Duchy x2
      And my deck contains 10 other cards
    When I play Tactician
      Then I should have discarded Copper x2, Duchy x2
    When the game checks actions
      Then it should be my Buy phase
    When my next turn starts
      Then the following 2 steps should happen at once
        Then I should have drawn 5 cards
        And I should have moved Tactician from enduring to play
      And I should have 2 actions available
      And I should have 2 buys available
        
  Scenario: Playing Tactician with nothing to discard
    Given my hand contains Tactician
    When I play Tactician
      Then nothing should have happened
    When the game checks actions
      Then it should be my Buy phase
    When my next turn starts
      Then I should have moved Tactician from enduring to play
      And I should have 1 action available
      And I should have 1 buy available

  Scenario: Still get to buy after Tactician
    Given my hand contains Tactician, Grand Market x2, Gold x2
      And my deck contains Gold x3
    When I play Grand Market
      Then I should have drawn 1 card
      And I should have 2 cash available
      And I should have 2 buys available
    When I play Grand Market
      Then I should have drawn 1 card
      And I should have 4 cash available
      And I should have 3 buys available
    When I play Tactician
      Then I should have discarded Gold x4
    When the game checks actions
      Then it should be my Buy phase
    When I buy Silver
      And the game checks actions
    Then I should have gained Silver
      And I should have 1 cash available
    When I buy Copper
      And the game checks actions
    Then I should have gained Copper
