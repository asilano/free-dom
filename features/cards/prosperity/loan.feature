Feature: Loan
  Treasure - 1 Cash.
    When you play this, reveal cards from your deck until you reveal a Treasure. Discard it or trash it. Discard the other cards.

  Background:
    Given I am a player in a standard game with Loan

  Scenario: Loan should be set up at game start
    Then there should be 10 Loan cards in piles
      And there should be 0 Loan cards not in piles

  Scenario: Playing Loan - trashing
    Given my hand contains Loan, Gold x3
      And my deck contains Estate, Smithy, Great Hall, Copper, Moat
      And it is my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then I should need to Play Treasure
      And I should be able to choose a nil action named Play Simple Treasures in my hand
      And I should be able to choose a nil action named Stop Playing Treasures in my hand
    When I play Loan as treasure
    Then I should have moved Estate, Smithy, Great Hall from deck to discard
      And I should be revealing Copper
      And I should need to Choose to Trash or Discard Copper
      And I should have 1 cash
    When I choose Trash for my revealed Copper
      Then I should have removed Copper from my deck
    When the game checks actions
      Then I should have played Gold x3

  Scenario: Playing Loan - discarding
    Given my hand contains Loan, Gold x3
      And my deck contains Estate, Smithy, Great Hall, Copper, Moat
      And it is my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then I should need to Play Treasure
    When I play Loan as treasure
    Then I should have moved Estate, Smithy, Great Hall from deck to discard
      And I should be revealing Copper
      And I should need to Choose to Trash or Discard Copper
      And I should have 1 cash
    When I choose Discard for my revealed Copper
      Then I should have moved Copper from deck to discard
    When the game checks actions
      Then I should have played Gold x3

  Scenario: Playing Loan - playing two Loans
    Given my hand contains Loan, Loan, Gold x3
      And my deck contains Estate, Smithy, Great Hall, Copper, Moat
      And I have Silver, Adventurer, Witch in discard
      And it is my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then I should need to Play Treasure
    When I play Loan as treasure
    Then I should have moved Estate, Smithy, Great Hall from deck to discard
      And I should be revealing Copper
      And I should need to Choose to Trash or Discard Copper
      And I should have 1 cash
    When I choose Trash for my revealed Copper
      Then I should have removed Copper from my deck
    When the game checks actions
      Then I should need to Play Treasure
    When I play Loan as treasure
    Then the following 2 steps should happen at once
      Then I should have shuffled my discards
      And I should have moved Moat, Adventurer, Estate, Great Hall from deck to discard
    And I should be revealing Silver
      And I should need to Choose to Trash or Discard Silver
      And I should have 2 cash
    When I choose Discard for my revealed Silver
      Then I should have moved Silver from deck to discard
    When the game checks actions
      Then I should have played Gold x3

  Scenario: Playing Loan - no treasures
    Given my hand contains Loan, Gold x3
      And my deck contains Estate, Smithy, Great Hall
      And it is my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then I should need to Play Treasure
    When I play Loan as treasure
    Then I should have moved Estate, Smithy, Great Hall from deck to discard
      And I should have 1 cash
    When the game checks actions
      Then I should have played Gold x3