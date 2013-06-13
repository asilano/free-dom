Feature: Coppersmith
  Copper produces an extra 1 cash this turn.

  Background:
    Given I am a player in a standard game with Coppersmith

  Scenario: Coppersmith should be set up at game start
    Then there should be 10 Coppersmith cards in piles
      And there should be 0 Coppersmith cards not in piles

  Scenario: Playing Coppersmith
    Given my hand contains Coppersmith, Copper, Copper, Silver, Bank  # force slow-play treasures
      And it is my Play Action phase
    When I play Coppersmith
      And the game checks actions
      Then I should need to Play treasure
    When I play Copper as treasure
      Then I should have 2 cash
    When the game checks actions
    And I play Copper as treasure
      Then I should have 4 cash
    When the game checks actions
    And I play Silver as treasure
      Then I should have 6 cash

  Scenario: Multiple Coppersmiths
    Given my hand contains Village, Coppersmith, Coppersmith, Copper, Copper, Silver, Bank  # force slow-play treasures
      And it is my Play Action phase
    When I play Village
      Then I should have drawn 1 card
    When I play Coppersmith
    And I play Coppersmith
    And the game checks actions
      Then I should need to Play treasure
    When I play Copper as treasure
      Then I should have 3 cash
    When the game checks actions
    And I play Copper as treasure
      Then I should have 6 cash
    When the game checks actions
    And I play Silver as treasure
      Then I should have 8 cash