Feature: Grand Market
  Draw 1 card, +1 Action, +1 Buy, +2 Cash. You can't buy this if you have any Copper in play.

  Background:
    Given I am a player in a standard game with Grand Market

  Scenario: Grand Market should be set up at game start
    Then there should be 10 Grand Market cards in piles
      And there should be 0 Grand Market cards not in piles

  Scenario: Playing Grand Market
    Given my hand contains Grand Market and 4 other cards
      And it is my Play Action phase
    When I play Grand Market
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 2 buys available
      And I should have 2 cash
      And it should be my Play Action phase

  Scenario: Playing multiple Grand Markets
    Given my hand contains Grand Market x2 and 4 other cards
      And it is my Play Action phase
    When I play Grand Market
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 2 buys available
      And I should have 2 cash
      And it should be my Play Action phase
    When I play Grand Market
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 3 buys available
      And I should have 4 cash
      And it should be my Play Action phase

  Scenario: Can't buy Grand Market with Copper
    Given my hand contains Gold, Silver, Copper
      And it is my Play Treasure phase
    When the game checks actions
      Then I should need to Play Treasure
    When I play simple treasures
      Then I should have played Gold, Silver, Copper
    When the game checks actions
      Then I should need to Buy
      And I should not be able to choose the Grand Market pile

  Scenario: Can buy Grand Market without Copper
    Given my hand contains Gold, Gold, Copper
      And it is my Play Treasure phase
    When the game checks actions
      Then I should need to Play Treasure
    When I play Gold as treasure
    And the game checks actions
    And I play Gold as treasure
    And the game checks actions
    And I stop playing treasures
      Then I should need to Buy
      And I should be able to choose the Grand Market pile
    When I buy Grand Market
    And the game checks actions
      Then the following 4 steps should happen at once
      Then I should have gained Grand Market
      And I should have moved Gold, Gold from play to discard
      And I should have discarded Copper
      And I should have drawn 5 cards
    And it should be Bob's Play Action phase

  Scenario: Grand Market doesn't hold up play if money's too tight
    Given my hand contains Copper
      And it is my Play Treasure phase
    When the game checks actions
      Then I should have played Copper
      And I should need to Buy

  Scenario: Grand Market doesn't hold up play if no Copper is held
    Given my hand contains Gold, Gold
      And it is my Play Treasure phase
    When the game checks actions
      Then I should have played Gold x2
      And I should need to Buy
      And I should be able to choose the Grand Market pile