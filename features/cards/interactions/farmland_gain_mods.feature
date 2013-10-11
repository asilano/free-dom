Feature: Buying Farmland and trashing an On-Gain card
  If you buy Farmland and trash a Trader or Watchtower in hand,
  that card shouldn't be around to apply to the upcoming gain of
  the bought Farmland

  Background:
    Given I am a player in a standard game with Farmland, Mint, Mine

  Scenario: Buying Farmland while holding only Trader
    Given my hand contains Woodcutter, Gold x2, Trader
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
    And I play simple treasures
    And the game checks actions
      Then I should have played Gold x2
      And it should be my Buy phase
    When I buy Farmland expecting side-effects
      Then I should have removed Trader from my hand
    When I choose the Gold pile
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Gold
        And I should have gained Farmland
      And it should be my Buy phase
      And I should have 2 cash available

  Scenario: Buying Farmland while holding two Traders
    Given my hand contains Woodcutter, Gold x2, Trader x2
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
    And I play simple treasures
    And the game checks actions
      Then I should have played Gold x2
      And it should be my Buy phase
    When I buy Farmland expecting side-effects
      Then I should have removed Trader from my hand
    When I choose the Gold pile
    And the game checks actions
      Then I should need to Choose whether to react with Trader
    When I choose the option Yes - gain Silver
    And the game checks actions
      Then I should have gained Silver
      And I should need to Choose whether to react with Trader
    When I choose the option No - gain Farmland
    And the game checks actions
      Then I should have gained Farmland
      And it should be my Buy phase
      And I should have 2 cash available

  Scenario: Buying Farmland while holding only Watchtower
    Given my hand contains Woodcutter, Gold x2, Watchtower
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
    And I play simple treasures
    And the game checks actions
      Then I should have played Gold x2
      And it should be my Buy phase
    When I buy Farmland expecting side-effects
      Then I should have removed Watchtower from my hand
    When I choose the Mine pile
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Mine
        And I should have gained Farmland
      And it should be my Buy phase
      And I should have 2 cash available
