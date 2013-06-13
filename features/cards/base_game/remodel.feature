Feature: Remodel
  Trash a card from your hand. Gain a card costing up to 2 more than the trashed card.

  Background:
    Given I am a player in a standard game with Remodel, Chapel, Woodcutter, Throne Room, Mint, Adventurer

  Scenario: Remodel should be set up at game start
    Then there should be 10 Remodel cards in piles
      And there should be 0 Remodel cards not in piles

  Scenario: Playing Remodel - choices in hand
    Given my hand contains Remodel, Copper, Estate and 2 other cards
      And it is my Play Action phase
    When I play Remodel
    Then I should need to Trash a card with Remodel
    When I choose Estate in my hand
    Then I should have removed Estate from my hand
      And I should need to Take a replacement card with Remodel
      And I should be able to choose the Copper, Silver, Estate, Chapel, Woodcutter, Throne Room piles
      And I should not be able to choose the Duchy, Gold, Mint, Adventurer piles
    When I choose the Throne Room pile
      And the game checks actions
    Then I should have gained Throne Room
      And I should need to Play treasure

  Scenario: Playing Remodel - only one type in hand
    Given my hand contains Remodel, Estate x2
      And it is my Play Action phase
    When I play Remodel
    Then I should have removed Estate from my hand
      And I should need to Take a replacement card with Remodel
      And I should be able to choose the Copper, Silver, Estate, Chapel, Woodcutter, Throne Room piles
      And I should not be able to choose the Duchy, Gold, Mint, Adventurer piles
    When I choose the Throne Room pile
      And the game checks actions
    Then I should have gained Throne Room
      And it should be my Buy phase

  Scenario: Playing Remodel - nothing in hand
    Given my hand contains Remodel
      And it is my Play Action phase
    When I play Remodel
    Then it should be my Play Treasure phase
