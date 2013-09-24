Feature: Haggler
  +2 Cash.
  While this is in play, when you buy a card, gain a card costing less than it that is not a Victory card.

  Background:
    Given I am a player in a standard game with Haggler, Cellar, Smithy, Witch, Forge, Peddler, Great Hall, Harem, Adventurer

  Scenario: Haggler should be set up at game start
    Then there should be 10 Haggler cards in piles
      And there should be 0 Haggler cards not in piles

  Scenario: Playing Haggler
    Given my hand contains Haggler and 4 other cards
      And it is my Play Action phase
    When I play Haggler
      Then I should have 2 cash
      And it should be my Play Treasure phase

  Scenario: Buying with Haggler
    Given my hand contains Market, Haggler, Silver x2
      And my deck contains Estate x5
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Haggler
    And the game checks actions
      Then I should have played Silver x2
      And it should be my Buy phase
    When I buy Smithy
    And the game checks actions
      Then I should need to Choose a card to gain with Haggler
      And I should be able to choose the Copper, Curse, Moat, Silver piles
      And I should not be able to choose the Estate, Great Hall, Smithy, Witch, Gold, Province piles
    When I choose the Silver pile
    And the game checks actions
      Then I should have gained Silver, Smithy
      And I should need to Buy

  Scenario: Buying with Haggler when card costs are changed by Quarry
    Given my hand contains Market, Haggler, Silver, Quarry
      And my deck contains Estate x5
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Haggler
    And the game checks actions
    Then I should have played Silver, Quarry
      And it should be my Buy phase
      And the Adventurer pile should cost 4
      And the Smithy pile should cost 2
    When I buy Adventurer
    And the game checks actions
      Then I should need to Choose a card to gain with Haggler
      And I should be able to choose the Copper, Curse, Moat, Silver, Smithy, Witch piles
      And I should not be able to choose the Estate, Great Hall, Gold, Province piles
    When I choose the Silver pile
    And the game checks actions
      Then I should have gained Silver, Adventurer
      And I should need to Buy

  Scenario: Buying with Haggler when card costs are changed by two Quarries
    Given my hand contains Market, Haggler, Quarry x2
      And my deck contains Estate x5
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Haggler
    And the game checks actions
      Then I should have played Quarry x2
      And it should be my Buy phase
      And the Adventurer pile should cost 2
      And the Smithy pile should cost 0
    When I buy Adventurer
    And the game checks actions
      Then I should need to Choose a card to gain with Haggler
      And I should be able to choose the Copper, Curse, Moat, Smithy, Witch piles
      And I should not be able to choose the Estate, Great Hall, Silver, Gold, Province piles
    When I choose the Moat pile
    And the game checks actions
      Then I should have gained Moat, Adventurer
      And I should need to Buy

  Scenario: Buying with Haggler when only 1 choice available
    Given my hand contains Market, Haggler
      And my deck contains Estate x5
      And the Curse pile is empty
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Haggler
    And the game checks actions
      Then it should be my Buy phase
    When I buy Moat
    And the game checks actions
      Then I should have gained Moat, Copper
     And I should need to Buy

  Scenario: Buying with Haggler when card costs 0 (!)
    Given my hand contains Market, Haggler, Quarry
      And my deck contains Province
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Haggler
    And the game checks actions
      Then I should have played Quarry
      And it should be my Buy phase
      And the Moat pile should cost 0
    When I buy Moat
      And the game checks actions
      Then I should have gained Moat
      And I should need to Buy

  Scenario: Buying when Haggler is in hand shouldn't trigger
    Given my hand contains Woodcutter, Haggler, Silver x2
    When I play Woodcutter
    And the game checks actions
      Then I should have played Silver x2
      And it should be my Buy phase
    When I buy Smithy
    And the game checks actions
      Then I should have gained Smithy
      And I should need to Buy