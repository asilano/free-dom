Feature: Forge
  Trash any number of cards from your hand. Gain a card with cost exactly equal to the total cash cost of the trashed cards.

  Background:
    Given I am a player in a standard game with Forge, Chapel, Woodcutter, Throne Room, Mint, Adventurer, Moat, Pawn, Smithy, Witch

  Scenario: Forge should be set up at game start
    Then there should be 10 Forge cards in piles
      And there should be 0 Forge cards not in piles

  Scenario: Playing Forge - total trashed is pickable 
    Given my hand contains Forge, Copper, Estate, Woodcutter, Throne Room, Mint, Adventurer
      And it is my Play Action phase
    When I play Forge
    Then I should need to Trash cards from hand with Forge
    When I choose Estate, Woodcutter in my hand
    Then I should have removed Estate, Woodcutter from my hand
      And I should need to Take a replacement card costing 5 with Forge
      And I should be able to choose the Mint, Witch, Duchy piles
      And I should not be able to choose the Copper, Estate, Chapel, Woodcutter, Throne Room, Gold, Adventurer, Forge piles
    When I choose the Witch pile
      And the game checks actions
    Then I should have gained Witch
      And I should need to Play Treasure

  Scenario: Playing Forge - no available replacement
    Given my hand contains Forge, Mint x2
      And it is my Play Action phase
    When I play Forge
    Then I should need to Trash cards from hand with Forge
    When I choose Mint, Mint in my hand
    Then I should have removed Mint, Mint from my hand
      And it should be my Play Treasure phase

  Scenario: Playing Forge - one available replacement
    Given my hand contains Forge, Estate x2, Woodcutter and 2 other cards
      And it is my Play Action phase
    When I play Forge
    Then I should need to Trash cards from hand with Forge
    When I choose Estate, Estate, Woodcutter in my hand
    Then I should have removed Estate, Estate, Woodcutter from my hand     
    When the game checks actions
    Then I should have gained Forge
      And I should need to Play Treasure
      
  Scenario: Playing Forge - nothing in hand
    Given my hand contains Forge
      And my deck is empty
      And it is my Play Action phase
    When I play Forge
    Then I should need to Take a replacement card costing 0 with Forge
      And I should be able to choose the Copper, Curse piles
    When I choose the Copper pile
      And the game checks actions
    Then I should have gained Copper
      And I should need to Play Treasure
