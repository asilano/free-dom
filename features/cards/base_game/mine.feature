Feature: Mine
  Trash a Treasure card from your hand. Gain a Treasure card costing up to 3 more, and put it into your hand.

  Background: Need Mint to hold up playing of treasures
    Given I am a player in a Platinum-Colony game with Mine, Harem, Talisman, Mint

  Scenario: Mine should be set up at game start
    Then there should be 10 Mine cards in piles
      And there should be 0 Mine cards not in piles

  Scenario: Playing Mine - multiple treasures in hand
    Given my hand contains Mine, Copper, Silver, Harem, Smithy
      And it is my Play Action phase
    When I play Mine
    Then I should need to Trash a card with Mine
      And I should be able to choose Copper, Silver, Harem in my hand
    When I choose Silver in my hand
    Then I should have removed Silver from hand
      And I should need to Take a replacement card with Mine
      And I should be able to choose the Copper, Silver, Gold, Harem, Talisman piles
      And I should not be able to choose the Platinum, Mine piles
    When I choose the Gold pile
    Then I should have placed Gold in my hand
      And I should need to Play treasures

  Scenario: Playing Mine - one treasure in hand
    Given my hand contains Mine, Talisman, Smithy, Gardens
      And it is my Play Action phase
      And I have 6 cash
    When I play Mine
    Then I should have removed Talisman from hand
      And I should need to Take a replacement card with Mine
      And I should be able to choose the Copper, Silver, Gold, Harem, Talisman piles
      And I should not be able to choose the Platinum, Mine piles
    When I choose the Harem pile
    Then I should have placed Harem in my hand
      And I should need to Play treasures

  Scenario: Playing Mine - no treasures in hand
    Given my hand contains Mine, Smithy, Gardens, Nobles
      And it is my Play Action phase
    When I play Mine
    Then it should be my Buy phase

  Scenario: Playing Mine - a treasure pile is empty
    Given my hand contains Mine, Talisman, Smithy, Gardens
      And the Talisman pile is empty
      And it is my Play Action phase
      And I have 6 cash
    When I play Mine
    Then I should have removed Talisman from hand
      And I should need to Take a replacement card with Mine
      And I should be able to choose the Copper, Silver, Gold, Harem piles
      And I should not be able to choose the Talisman pile
      And I should not be able to choose the Platinum, Mine piles
    When I choose the Harem pile
    Then I should have placed Harem in my hand
      And I should need to Play treasures