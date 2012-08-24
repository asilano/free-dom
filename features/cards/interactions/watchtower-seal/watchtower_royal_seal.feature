Feature: Watchtower + Royal Seal
  If a Royal Seal is in play and a Watchtower is in hand, then can choose the normal destination for one and still answer the other;
    Or choose a different destination for the first, and then the other disappears.

  Background:
    Given I am a player in a standard game

  Scenario: Discard to Seal, then Deck to Watchtower
    Given my hand contains Gold, Royal Seal, Watchtower
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold, Royal Seal
      And I should need to buy
    When I buy Silver
    And the game checks actions
      Then I should need to Choose whether to place Silver on top of deck
      And I should need to Decide on destination for Silver
    When I choose the option Discard
      Then I should need to Decide on destination for Silver
    When I choose the option Yes - Silver on deck
      Then I should have put Silver on top of my deck

  Scenario: Discard to Watchtower, then Deck to Seal
    Given my hand contains Gold, Royal Seal, Watchtower
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold, Royal Seal
      And I should need to buy
    When I buy Silver
    And the game checks actions
      Then I should need to Choose whether to place Silver on top of deck
      And I should need to Decide on destination for Silver
    When I choose the option No - Silver to discard
      Then I should need to Choose whether to place Silver on top of deck
    When I choose the option On deck
      Then I should have put Silver on top of my deck

  Scenario: Deck to Seal, Watchtower vanishes
    Given my hand contains Gold, Royal Seal, Watchtower
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold, Royal Seal
      And I should need to buy
    When I buy Silver
    And the game checks actions
      Then I should need to Choose whether to place Silver on top of deck
      And I should need to Decide on destination for Silver
    When I choose the option On deck
      Then I should have put Silver on top of my deck
      And I should not need to act

  Scenario: Deck to Watchtower, Seal vanishes
    Given my hand contains Gold, Royal Seal, Watchtower
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold, Royal Seal
      And I should need to buy
    When I buy Silver
    And the game checks actions
      Then I should need to Choose whether to place Silver on top of deck
      And I should need to Decide on destination for Silver
    When I choose the option Yes - Silver on deck
      Then I should have put Silver on top of my deck
      And I should not need to act