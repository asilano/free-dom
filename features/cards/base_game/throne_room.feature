Feature: Throne Room
  Choose an action card in your hand. Play it twice.

  Background:
    Given I am a player in a standard game with Throne Room

  Scenario: Throne Room should be set up at game start
    Then there should be 10 Throne Room cards in piles
    And there should be 0 Throne Room cards not in piles

  Scenario: Playing Throne Room - choice of card
    Given my hand contains Throne Room, Village, Smithy and 2 other cards
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play Throne Room
    Then I should need to Choose a card to play with Throne Room
    When I choose Village in my hand
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have played Village
      And I should have drawn 2 cards
    And I should have 4 actions available

  Scenario: Playing Throne Room - only one card
    Given my hand contains Throne Room, Village, Copper x3
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play Throne Room
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have played Village
      And I should have drawn 2 cards
    And I should have 4 actions available

  Scenario: Playing Throne Room - no actions
    Given my hand contains Throne Room, Copper x3
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play Throne Room
    Then it should be my Play Treasure phase

  Scenario: Playing Throne Room - can Throne Room a Throne Room
    Given my hand contains Throne Room x2, Village, Smithy, Copper x2
      And it is my Play Action phase
      And my deck contains Gold x10
    When I play Throne Room
    Then I should need to Choose a card to play with Throne Room
    When I choose Throne Room in my hand
      And the game checks actions
    Then I should have played Throne Room
      And I should need to Choose a card to play with Throne Room
    When I choose Village in my hand
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have played Village
      And I should have drawn 2 cards
      And I should have played Smithy
      And I should have drawn 6 cards
    And I should have 4 actions available
   
