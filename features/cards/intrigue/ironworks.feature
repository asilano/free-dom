Feature: Ironworks
  Gain a card costing up to 4. If it's an: Action => +1 Action; Treasure => +1 Cash; Victory => Draw 1 card.

  Background:
    Given I am a player in a standard game with Ironworks, Cellar, Great Hall, Bridge, Mine, Harem, Bank, Peddler

  Scenario: Ironworks should be set up at game start
    Then there should be 10 Ironworks cards in piles
      And there should be 0 Ironworks cards not in piles

  Scenario: Playing Ironworks - Action
    Given my hand contains Ironworks, Duchy x4
      And I have nothing in discard
      And the Cellar pile is empty
    When I play Ironworks
    Then I should need to Take a card with Ironworks
      And I should be able to choose the Estate, Copper, Silver, Great Hall, Ironworks, Bridge piles
      And I should not be able to choose the Duchy, Province, Gold, Cellar, Harem, Bank, Mine, Peddler piles
    When I choose the Bridge pile
      And the game checks actions
    Then I should have gained Bridge
      And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Ironworks - Treasure
    Given my hand contains Ironworks, Duchy x4
      And I have nothing in discard
      And the Cellar pile is empty
    When I play Ironworks
    Then I should need to Take a card with Ironworks
      And I should be able to choose the Estate, Copper, Silver, Great Hall, Ironworks, Bridge piles
      And I should not be able to choose the Duchy, Province, Gold, Cellar, Harem, Bank, Mine, Peddler piles
    When I choose the Silver pile
      And the game checks actions
    Then I should have gained Silver
      And it should be my Buy phase
      And I should have 1 cash

  Scenario: Playing Ironworks - Victory
    Given my hand contains Ironworks, Duchy x4
      And I have nothing in discard
      And my deck contains Duchy
      And the Cellar pile is empty
    When I play Ironworks
    Then I should need to Take a card with Ironworks
      And I should be able to choose the Estate, Copper, Silver, Great Hall, Ironworks, Bridge piles
      And I should not be able to choose the Duchy, Province, Gold, Cellar, Harem, Bank, Mine, Peddler piles
    When I choose the Estate pile
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Estate
      And I should have drawn 1 card
    And it should be my Buy phase

  Scenario: Playing Ironworks - Action/Victory
    Given my hand contains Ironworks, Duchy x4
      And I have nothing in discard
      And the Cellar pile is empty
    When I play Ironworks
    Then I should need to Take a card with Ironworks
      And I should be able to choose the Estate, Copper, Silver, Great Hall, Ironworks, Bridge piles
      And I should not be able to choose the Duchy, Province, Gold, Cellar, Harem, Bank, Mine, Peddler piles
    When I choose the Great Hall pile
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Great Hall
      And I should have drawn 1 card
    And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Ironworks - Treasure/Victory
    Given my hand contains Ironworks, Duchy x4
      And I have nothing in discard
      And my deck contains Duchy
      And the Cellar pile is empty
      And the game fact "bridges" is 2
    When I play Ironworks
    Then I should need to Take a card with Ironworks
      And I should be able to choose the Estate, Duchy, Copper, Silver, Gold, Great Hall, Ironworks, Bridge, Mine, Harem piles
      And I should not be able to choose the Province, Cellar, Bank, Peddler piles
    When I choose the Harem pile
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Harem
      And I should have drawn 1 card
    And it should be my Buy phase
      And I should have 1 cash