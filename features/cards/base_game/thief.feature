Feature: Thief
  Attack - Draw 1 card, +1 Action. Each other player reveals the top two cards of his deck. If they revealed any Treasure cards, they trash one of them that you choose. You may gain any or all of the trashed cards. They discard the other revealed cards.

  Background:
    Given I am a player in a standard game with Thief

  Scenario: Thief should be set up at game start
    Then there should be 10 Thief cards in piles
      And there should be 0 Thief cards not in piles

  Scenario: Playing Thief - Steal from 2 & Trash from 2
    Given my hand contains Thief and 4 other cards
      And Bob's deck contains Gold, Copper and 3 other cards
      And Charlie's deck contains Copper, Loan
    When I play Thief
    And the game checks actions
      Then Bob should be revealing Gold, Copper
      And Charlie should be revealing Copper, Loan
      And I should need to Choose Thief actions for Bob
      And I should need to Choose Thief actions for Charlie
    When I choose Trash and Take for Bob's revealed Gold
    And the game checks actions
      Then the following 3 steps should happen at once
        Then Bob should have removed Gold from his deck
        And I should have gained Gold
        And Bob should have moved Copper from deck to discard
    When I choose Just Trash for Charlie's revealed Loan
      Then the following 2 steps should happen at once
        Then Charlie should have removed Loan from his deck
        And Charlie should have moved Copper from deck to discard
      And it should be my Play Treasure phase

  Scenario: Playing Thief - Steal from 1+1 & Trash from 1+1
    Given my hand contains Thief and 4 other cards
      And Bob's deck contains Gold, Moat and 3 other cards
      And Charlie's deck contains Smithy, Loan
    When I play Thief
    And the game checks actions
      Then Bob should be revealing Gold, Moat
      And Charlie should be revealing Smithy, Loan
      And I should need to Choose Thief actions for Bob
      And I should need to Choose Thief actions for Charlie
    When I choose Trash and Take for Bob's revealed Gold
    And the game checks actions
      Then the following 3 steps should happen at once
        Then Bob should have removed Gold from his deck
        And I should have gained Gold
        And Bob should have moved Moat from deck to discard
    When I choose Just Trash for Charlie's revealed Loan
      Then the following 2 steps should happen at once
        Then Charlie should have removed Loan from his deck
        And Charlie should have moved Smithy from deck to discard
      And it should be my Play Treasure phase

  Scenario: Playing Thief - Steal from 1 & Trash from 1
    Given my hand contains Thief and 4 other cards
      And Bob's deck contains Gold and 3 other cards
      And Charlie's deck contains Loan
    When I play Thief
    And the game checks actions
      Then Bob should be revealing Gold
      And Charlie should be revealing Loan
      And I should need to Choose Thief actions for Bob
      And I should need to Choose Thief actions for Charlie
    When I choose Trash and Take for Bob's revealed Gold
    And the game checks actions
      Then the following 2 steps should happen at once
        Then Bob should have removed Gold from his deck
        And I should have gained Gold
    When I choose Just Trash for Charlie's revealed Loan
      Then Charlie should have removed Loan from his deck
      And it should be my Play Treasure phase

  Scenario: Playing Thief - Whiff, and no cards
    Given my hand contains Thief, Bank and 4 other cards # need Bank to halt play
      And Bob's deck contains Smithy, Moat and 3 other cards
      And Charlie's deck is empty
    When I play Thief
    And the game checks actions
      Then Bob should have moved Smithy, Moat from deck to discard
      And I should need to Play Treasure
