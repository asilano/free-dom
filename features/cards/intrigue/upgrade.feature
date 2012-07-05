Feature: Upgrade
  Draw 1 card, +1 Action. Trash a card from your hand. Gain a card costing exactly 1 more than the trashed card.

  Background:
    Given I am a player in a standard game with Upgrade, Chapel, Woodcutter, Throne Room, Mint, Adventurer, Moat, Pawn, Smithy, Witch

  Scenario: Upgrade should be set up at game start
    Then there should be 10 Upgrade cards in piles
      And there should be 0 Upgrade cards not in piles

  Scenario: Playing Upgrade - choices in hand 
    Given my hand contains Upgrade, Copper, Estate and 2 other cards
      And it is my Play Action phase
    When I play Upgrade
    Then I should have drawn 1 card
      And I should need to Upgrade a card
    When I choose Estate in my hand
    Then I should have removed Estate from my hand
      And I should need to Take a replacement card with Upgrade
      And I should be able to choose the Silver, Woodcutter piles
      And I should not be able to choose the Copper, Estate, Chapel, Throne Room, Duchy, Gold, Mint, Adventurer piles
    When I choose the Woodcutter pile
      And the game checks actions
    Then I should have gained Woodcutter
      And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Upgrade - only one type in hand
    Given my hand contains Upgrade, Estate x2
      And my deck contains Estate
      And it is my Play Action phase
    When I play Upgrade
    Then the following 2 steps should happen at once
      Then I should have drawn 1 card
      And I should have removed Estate from my hand
    And I should need to Take a replacement card with Upgrade
      And I should be able to choose the Silver, Woodcutter piles
      And I should not be able to choose the Copper, Estate, Chapel, Throne Room, Duchy, Gold, Mint, Adventurer piles
    When I choose the Woodcutter pile
      And the game checks actions
    Then I should have gained Woodcutter
      And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Upgrade - no available upgrade
    Given my hand contains Upgrade, Copper, Estate and 2 other cards
      And it is my Play Action phase
    When I play Upgrade
    Then I should have drawn 1 card
      And I should need to Upgrade a card
    When I choose Copper in my hand
    Then I should have removed Copper from my hand
    And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Upgrade - one available upgrade
    Given my hand contains Upgrade, Copper, Estate and 2 other cards
      And the Woodcutter pile is empty
      And it is my Play Action phase
    When I play Upgrade
    Then I should have drawn 1 card
      And I should need to Upgrade a card
    When I choose Estate in my hand
    Then I should have removed Estate from my hand      
    When the game checks actions
    Then I should have gained Silver
      And it should be my Play Action phase
      And I should have 1 action available
      
  Scenario: Playing Upgrade - nothing in hand
    Given my hand contains Upgrade
      And my deck is empty
      And it is my Play Action phase
    When I play Upgrade
    Then it should be my Play Action phase
      And I should have 1 action available
