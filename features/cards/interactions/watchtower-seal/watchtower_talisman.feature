Feature: Watchtower + Talisman

  Background:
    Given I am a player in a standard game with Feast

  Scenario: Buy cheap cards with Talisman + Watchtower
  # The Watchtower explicitly affects "gains", so the extra copies gained
  # by Talisman are eligible for top-of-deck treatment.

    Given my hand contains Woodcutter, Talisman, Watchtower, Gold x2
      And it is my Play Action phase
    When I play Woodcutter
      Then I should have 2 buys available
    When the game checks actions
      Then I should have played Talisman, Gold x2
      And it should be my Buy phase
      And I should have 9 cash available
    When I buy Silver
      And the game checks actions
    Then I should need to Decide on destination for Silver
    When I choose the option Yes - Silver on deck
      Then I should have put Silver on top of my deck
    When the game checks actions
      Then I should need to Decide on destination for Silver
    When I choose the option Yes - Silver on deck
      Then I should have put Silver on top of my deck
      And I should need to Buy
    When I buy Feast
      And the game checks actions
    Then I should need to Decide on destination for Feast
    When I choose the option Yes - trash Feast
      Then nothing should have happened
    When the game checks actions
      Then I should need to Decide on destination for Feast
    When I choose the option No - Feast to discard
      Then I should have gained Feast

  Scenario: 2x Talisman and 2x Watchtower
    Given my hand contains Woodcutter, Talisman x2, Watchtower x2, Gold x2
      And it is my Play Action phase
    When I play Woodcutter
      Then I should have 2 buys available
    When the game checks actions
      Then I should have played Talisman x2, Gold x2
      And it should be my Buy phase
      And I should have 10 cash available
    When I buy Silver
      And the game checks actions
    Then I should need to Decide on destination for Silver
    When I choose the option Yes - Silver on deck
      Then I should have put Silver on top of my deck
    When the game checks actions
      Then I should need to Decide on destination for Silver
    When I choose the option No - Silver to discard
      Then I should have gained Silver
    When the game checks actions
      Then I should need to Decide on destination for Silver
    When I choose the option Yes - trash Silver
      Then nothing should have happened
      And I should need to Buy
