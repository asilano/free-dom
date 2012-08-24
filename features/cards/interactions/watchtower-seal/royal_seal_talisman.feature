Feature: Royal Seal + Talisman

  Background:
    Given I am a player in a standard game with Feast

  Scenario: Buy cheap cards with Talisman + Royal Seal
  # The Royal Seal explicitly affects "gains", so the extra copies gained
  # by Talisman are eligible for top-of-deck treatment.

    Given my hand contains Woodcutter, Talisman, Royal Seal, Gold
      And it is my Play Action phase
    When I play Woodcutter
      Then I should have 2 buys available
    When the game checks actions
      Then I should have played Talisman, Royal Seal, Gold
      And it should be my Buy phase
      And I should have 8 cash available
    When I buy Silver
      And the game checks actions
    Then I should need to Choose whether to place Silver on top of deck
    When I choose the option On deck
      Then I should have put Silver on top of my deck
    When the game checks actions
      Then I should need to Choose whether to place Silver on top of deck
    When I choose the option On deck
      Then I should have put Silver on top of my deck
      And I should need to Buy
    When I buy Feast
      And the game checks actions
    Then I should need to Choose whether to place Feast on top of deck
    When I choose the option On deck
      Then I should have put Feast on top of my deck
    When the game checks actions
      Then I should need to Choose whether to place Feast on top of deck
    When I choose the option Discard
      Then I should have gained Feast

  Scenario: 2x Talisman and 2x Royal Seal
    Given my hand contains Woodcutter, Talisman x2, Royal Seal x2, Gold
      And it is my Play Action phase
    When I play Woodcutter
      Then I should have 2 buys available
    When the game checks actions
      Then I should have played Talisman x2, Royal Seal x2, Gold
      And it should be my Buy phase
      And I should have 11 cash available
    When I buy Silver
      And the game checks actions
    Then I should need to Choose whether to place Silver on top of deck
    When I choose the option On deck
      Then I should have put Silver on top of my deck
    When the game checks actions
      Then I should need to Choose whether to place Silver on top of deck
    When I choose the option Discard
      Then I should have gained Silver
    When the game checks actions
      Then I should need to Choose whether to place Silver on top of deck
    When I choose the option Discard
      Then I should have gained Silver
      And I should need to Buy
