Feature: Trading Post
  Trash 2 cards from your hand. If you do, gain a Silver card to your hand.

  Background:
    Given I am a player in a standard game with Trading Post, Mint

  Scenario: Trading Post should be set up at game start
    Then there should be 10 Trading Post cards in piles
      And there should be 0 Trading Post cards not in piles

  Scenario: Playing Trading Post - multiple cards in hand
    Given my hand contains Trading Post, Copper, Copper, Curse
      And I have 6 cash
    When I play Trading Post
    Then I should need to Trash two cards with Trading Post
    When I choose Curse in my hand
    Then I should have removed Curse from my hand
      And I should need to Trash one card with Trading Post
    When I choose Copper in my hand
    Then I should have removed Copper from my hand
    When the game checks actions
    Then I should have placed Silver in my hand
      And I should need to Play Treasure

  Scenario: Playing Trading Post - two different cards in hand
    Given my hand contains Trading Post, Copper, Curse
      And I have 6 cash
    When I play Trading Post
    Then I should have removed Curse, Copper from my hand
    When the game checks actions
    Then I should have placed Silver in my hand
      And I should need to Play Treasure

  Scenario: Playing Trading Post - identical cards in hand
    Given my hand contains Trading Post, Copper x3
      And I have 6 cash
    When I play Trading Post
    Then I should have removed Copper, Copper from my hand
    When the game checks actions
    Then I should have placed Silver in my hand
      And I should need to Play Treasure

  Scenario: Playing Trading Post - one card in hand
    Given my hand contains Trading Post, Copper
    When I play Trading Post
    Then I should have removed Copper from my hand
      And it should be my Play Treasure phase

  Scenario: Playing Trading Post - no cards in hand
    Given my hand contains Trading Post
    When I play Trading Post
    Then it should be my Play Treasure phase