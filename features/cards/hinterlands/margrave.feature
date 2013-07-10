Feature: Margrave
  Draw 3 cards, +1 Buy. Each other player draws a card, then discards down to 3 cards in hand.

  Background:
    Given I am a player in a standard game with Margrave

  Scenario: Margrave should be set up at game start
    Then there should be 10 Margrave cards in piles
      And there should be 0 Margrave cards not in piles

  Scenario: Playing Margrave - opponents can discard
    Given my hand contains Village, Margrave, Estate
      And my deck contains Estate, Gold x3
      And Bob's hand contains Copper, Silver, Estate, Curse, Smithy
      And Bob's deck contains Duchy
      And Charlie's hand contains Province, Colony, Gardens, Duchy
      And Charlie's deck is empty
    When I play Village
      Then I should have drawn a card
    When I play Margrave
      Then I should have drawn 3 cards
      And I should have 2 buys available
    When the game checks actions
      Then Bob should have drawn a card
      And Bob should need to Discard 3 cards to Margrave
      And Charlie should need to Discard 1 card to Margrave
      And I should not need to act
    When Bob chooses Estate in his hand
      Then Bob should have discarded Estate
    When Charlie chooses Duchy in his hand
      Then Charlie should have discarded Duchy
    When Bob chooses Curse in his hand
      Then Bob should have discarded Curse
    When Bob chooses Copper in his hand
      Then Bob should have discarded Copper
      And I should need to Play Action

  Scenario: Playing Margrave - opponents can't discard
    Given my hand contains Village, Margrave, Estate
      And my deck contains Estate, Gold x1
      And Bob's hand contains Copper, Silver
      And Bob's deck contains Duchy
      And Charlie's hand contains Province
      And Charlie's deck is empty
    When I play Village
      Then I should have drawn a card
    When I play Margrave
      Then I should have drawn a card
      And I should have 2 buys available
    When the game checks actions
      Then Bob should have drawn a card
      And Bob should not need to act
      And Charlie should not need to act
      And I should need to Play Action

  Scenario: Playing Margrave - opponents discard is forced
    Given my hand contains Village, Margrave, Estate
      And my deck contains Gold x3
      And Bob's hand contains Copper x5
      And Bob's deck contains Copper
      And Charlie's hand contains Province x4
      And Charlie's deck is empty
    When I play Village
      Then I should have drawn a card
    When I play Margrave
      Then I should have drawn 3 cards
      And I should have 2 buys available
    When the game checks actions
      Then the following 3 steps should happen at once
        And Bob should have drawn a card
        And Bob should have discarded Copper x3
        And Charlie should have discarded Province
      And I should need to Play Action