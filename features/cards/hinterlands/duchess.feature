Feature: Duchess - Action: 2
  +2 Cash
  Each player (including you) looks at the top card of his deck, and discards it or puts it back.
  ----------
  In games using this, when you gain a Duchy, you may gain a Duchess.

  Background:
    Given I am a player in a standard game with Duchess

  Scenario: Duchess should be set up at game start
    Then there should be 10 Duchess cards in piles
      And there should be 0 Duchess cards not in piles
      And the Duchess pile should cost 2

  Scenario: Playing Duchess
    Given my hand contains Duchess, and 4 other cards
      And my deck contains Copper, Silver
      And Bob's deck is empty
      And Bob has Gold, Smithy in discard
      And Charlie's deck is empty
      And it is my Play Action phase
    When I play Duchess
      Then Bob should have shuffled his discards
      And I should have seen Copper
      And Bob should have seen Gold
      And Charlie should have seen nothing
      And I should have 2 cash
      And I should need to Choose whether to discard the seen card, with Duchess
      And Bob should need to Choose whether to discard the seen card, with Duchess
    When I choose the option Discard Copper from deck
      Then I should have moved Copper from deck to discard
    When Bob chooses the option Leave Gold on deck
      Then nothing should have happened
      And it should be my Play Treasure phase

  Scenario: Gaining Duchy, both Buy and non-Buy
    Given my hand contains Silver, Remodel, Silver x2, Copper
      And it is my Play Action phase
    When I play Remodel
    And I choose Silver in my hand
      Then I should have removed Silver from my hand
    When I choose the Duchy pile
    And the game checks actions
      Then I should have gained Duchy
      And I should need to Choose whether to gain a Duchess
    When I choose the option Gain a Duchess
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Duchess
        And I should have played Silver x2, Copper as treasures
    When I buy Duchy
    And the game checks actions
      Then I should have gained Duchy
      And I should need to Choose whether to gain a Duchess
    When I choose the option Gain a Duchess
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have gained Duchess
        And I should have moved Remodel, Silver x2, Copper from play to discard
        And I should have drawn 5 cards
    And it should be Bob's Play Action phase

  Scenario: Buying a Duchy when Duchess pile is empty
    Given my hand contains Silver, Remodel, Estate
      And the Duchess pile is empty
      And it is my Play Action phase
    When I play Remodel
    And I choose Silver in my hand
      Then I should have removed Silver from my hand
    When I choose the Duchy pile
    And the game checks actions
      Then I should have gained Duchy
      And it should be my Buy phase

  Scenario: Gaining Duchy when Duchess isn't in the game
    Given I am a player in a standard game
      And my hand contains Silver, Remodel, Estate
      And it is my Play Action phase
    When I play Remodel
    And I choose Silver in my hand
      Then I should have removed Silver from my hand
    When I choose the Duchy pile
    And the game checks actions
      Then I should have gained Duchy
      And it should be my Buy phase