Feature: Embassy
  Draw 5 cards. Discard 3 cards.
  When you gain this, each other player gains a Silver.

  Background:
    Given I am a player in a standard game with Embassy

  Scenario: Embassy should be set up at game start
    Then there should be 10 Embassy cards in piles
      And there should be 0 Embassy cards not in piles

  Scenario: Playing Embassy
    Given my hand contains Embassy, Estate, Gold, Market
      And my deck contains Copper, Silver, Gold, Smithy, Curse, Duchy
      And it is my Play Action phase
    When I play Embassy
      Then I should have drawn 5 cards
      And I should need to discard 3 cards
      And I should be able to choose Estate, Gold, Curse, Copper, Silver, Smithy, Market in my hand
      And I should not be able to choose a nil action in my hand
    When I choose Curse in my hand
      Then I should have discarded Curse
      And I should need to discard 2 cards
      And I should be able to choose Estate, Gold, Copper, Silver, Smithy, Market in my hand
      And I should not be able to choose a nil action in my hand
    When I choose Copper in my hand
      Then I should have discarded Copper
      And I should need to discard 1 card
      And I should be able to choose Estate, Gold, Silver, Smithy, Market in my hand
      And I should not be able to choose a nil action in my hand
    When I choose Estate in my hand
      Then I should have discarded Estate
      And it should be my Play Treasure phase

  Scenario: Playing Embassy, can't draw 5
    Given my hand contains Embassy, Estate, Gold, Curse
      And my deck contains Copper, Silver, Gold
      And it is my Play Action phase
    When I play Embassy
      Then I should have drawn 3 cards
      And I should need to discard 3 cards
      And I should be able to choose Estate, Gold, Curse, Copper, Silver in my hand
      And I should not be able to choose a nil action in my hand
    When I choose Curse in my hand
      Then I should have discarded Curse
      And I should need to discard 2 cards
      And I should be able to choose Estate, Gold, Copper, Silver in my hand
      And I should not be able to choose a nil action in my hand
    When I choose Copper in my hand
      Then I should have discarded Copper
      And I should need to discard 1 card
      And I should be able to choose Estate, Gold, Silver in my hand
      And I should not be able to choose a nil action in my hand
    When I choose Estate in my hand
      Then I should have discarded Estate
      And it should be my Play Treasure phase

  Scenario: Playing Embassy, can't draw 5 or discard 3
    Given my hand contains Embassy
      And my deck contains Copper, Silver
      And it is my Play Action phase
    When I play Embassy
      Then the following 2 steps should happen at once
        Then I should have drawn 2 cards
        And I should have discarded Copper, Silver
      And it should be my Play Treasure phase

  Scenario: Playing Embassy, all cards in hand the same
    Given my hand contains Embassy, Estate
      And my deck contains Estate x6
      And it is my Play Action phase
    When I play Embassy
      Then the following 2 steps should happen at once
        Then I should have drawn 5 cards
        And I should have discarded Estate x3
      And it should be my Play Treasure phase

  Scenario: Gaining Embassy: Buy and non-Buy
    Given my hand contains Silver, Remodel, Silver x2, Market
      And my deck contains Estate x6
      And Bob's hand contains Smuggler
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Remodel
    And I choose Silver in my hand
      Then I should have removed Silver from my hand
    When I choose the Embassy pile
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have gained Embassy
        And Bob should have gained Silver
        And Charlie should have gained Silver
        And I should have played Silver x2 as treasures
    When I buy Embassy
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have gained Embassy
        And Bob should have gained Silver
        And Charlie should have gained Silver
    When Bob's next turn starts
    And Bob plays Smuggler
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have gained Silver
        And Bob should have gained Embassy
        And Charlie should have gained Silver