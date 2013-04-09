Feature: Watchtower + Royal Seal + Nomad Camp
  If a Royal Seal is in play and a Watchtower is in hand, then gaining Nomad Camp (which already puts itself on deck)
    should trip Watchtower only - not Royal Seal. Watchtower should only provide "Trash" and "Normal" options.

  Background:
    Given I am a player in a standard game with Nomad Camp

  Scenario: Buy Nomad Camp; ensure no Seal action; trash to Watchtower
    Given my hand contains Gold, Royal Seal, Watchtower
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold, Royal Seal
      And I should need to buy
    When I buy Nomad Camp
    And the game checks actions
      Then I should not need to Choose whether to place Silver on top of deck
      And I should need to Decide on destination for Nomad Camp
      And I should be able to choose the option Yes - trash Nomad Camp
      And I should be able to choose the option No - Nomad Camp to deck
      And I should not be able to choose the option Yes - Nomad Camp on deck
    When I choose the option Yes - trash Nomad Camp
      Then nothing should have happened