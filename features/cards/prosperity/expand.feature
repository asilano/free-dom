Feature: Expand
  Trash a card from your hand. Gain a card costing up to 3 more than the trashed card.

  Background:
    Given I am a player in a standard game with Expand, Chapel, Woodcutter, Throne Room, Mint, Adventurer

  Scenario: Expand should be set up at game start
    Then there should be 10 Expand cards in piles
      And there should be 0 Expand cards not in piles

  Scenario: Playing Expand - choices in hand
    Given my hand contains Expand, Copper, Estate, Duchy, Witch
      And it is my Play Action phase
    When I play Expand
    Then I should need to Trash a card with Expand
    When I choose Estate in my hand
    Then I should have removed Estate from my hand
      And I should need to Take a replacement card with Expand
      And I should be able to choose the Copper, Silver, Estate, Duchy, Chapel, Woodcutter, Throne Room, Mint piles
      And I should not be able to choose the Gold, Adventurer piles
    When I choose the Throne Room pile
      And the game checks actions
    Then I should have gained Throne Room
      And I should need to Play treasure

  Scenario: Playing Expand - only one type in hand
    Given my hand contains Expand, Estate x2
      And it is my Play Action phase
    When I play Expand
    Then I should have removed Estate from my hand
      And I should need to Take a replacement card with Expand
      And I should be able to choose the Copper, Silver, Estate, Duchy, Chapel, Woodcutter, Throne Room, Mint piles
      And I should not be able to choose the Gold, Adventurer piles
    When I choose the Throne Room pile
      And the game checks actions
    Then I should have gained Throne Room
      And I should need to Buy

  Scenario: Playing Expand - nothing in hand
    Given my hand contains Expand
      And it is my Play Action phase
    When I play Expand
    Then it should be my Play Treasure phase
