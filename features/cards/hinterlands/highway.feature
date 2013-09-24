Feature: Highway
  Draw 1 card, +1 Action.
  While this is in play, cards cost 1 cash less, but not less than 0.

  Background:
    Given I am a player in a standard game with Highway, Moat, Village, Smithy, Market, Adventurer, Forge

  Scenario: Highway should be set up at game start
    Then there should be 10 Highway cards in piles
      And there should be 0 Highway cards not in piles

  Scenario: Playing Highway
    Given I am a player in a standard game
      And my hand contains Highway and 4 other cards
      And it is my Play Action phase
    When I play Highway
    Then I should have drawn 1 card
      And I should have 1 action available
      And it should be my Play Action phase

  Scenario: Discounting with Highway
    Given my hand contains Highway, Market x2, Copper, Estate x2
      And my deck contains Duchy
      And it is my Play Action phase
    When I play Market
    Then I should have drawn a card
      And I should have 1 cash
      And I should have 2 buys available
    When I play Market
    Then I should have drawn a card
      And I should have 2 cash
      And I should have 3 buys available
    When I play Highway
      Then the Copper pile should cost 0
      And the Moat pile should cost 1
      And the Village pile should cost 2
      And the Market pile should cost 4
    When I stop playing actions
    And the game checks actions
      Then I should have played Copper
      And I should have 3 cash
      And I should need to Buy
      And I should be able to choose the Copper, Moat, Village, Smithy piles
      And I should not be able to choose the Market, Adventurer piles
    When I buy Moat
      And the game checks actions
    Then I should have gained Moat
    When I buy Village
      And the game checks actions
    Then I should have gained Village

  Scenario: Multiple Highways
    Given my hand contains Highway x3, Gold
      And it is my Play Action phase
      And my deck contains Curse x5
    When I play Highway
      Then I should have drawn 1 card
    When I play Highway
      Then I should have drawn 1 card
    When I play Highway
      Then I should have drawn 1 card
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold
      And the Copper pile should cost 0
      And the Moat pile should cost 0
      And the Village pile should cost 0
      And the Smithy pile should cost 1
      And the Market pile should cost 2
      And I should need to Buy
      And I should be able to choose the Copper, Moat, Village, Smithy, Market, Adventurer piles
      And I should not be able to choose the Forge pile