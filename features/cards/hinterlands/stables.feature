Feature: Stables
  You may discard a Treasure. If you do, draw 3 cards and +1 Action.

  Background:
    Given I am a player in a standard game with Stables

  Scenario: Stables should be set up at game start
    Then there should be 10 Stables cards in piles
      And there should be 0 Stables cards not in piles

  Scenario: Play Stables - discard
    Given my hand contains Stables, Smithy, Harem, Silver
      And my deck contains 5 cards
      And it is my Play Action phase
    When I play Stables
      Then I should need to Discard a Treasure with Stables
      And I should be able to choose Harem, Silver in my hand
      And I should be able to choose a nil action in my hand
    When I choose Harem in my hand
      Then the following 2 steps should happen at once
        Then I should have discarded Harem
        And I should have drawn 3 cards
      And I should have 1 action available
      And I should need to Play Action

  Scenario: Play Stables - choose not to discard
    Given my hand contains Stables, Smithy, Copper, Silver
      And my deck contains 5 cards
      And it is my Play Action phase
    When I play Stables
      Then I should need to Discard a Treasure with Stables
      And I should be able to choose Copper, Silver in my hand
      And I should be able to choose a nil action in my hand
    When I choose Don't discard in my hand
    And the game checks actions
      Then I should have played Copper, Silver
      And I should need to Buy

  Scenario: Play Stables - can't discard
    Given my hand contains Stables, Smithy, Witch, Curse
      And my deck contains 5 cards
      And it is my Play Action phase
    When I play Stables
    And the game checks actions
      Then I should need to Buy