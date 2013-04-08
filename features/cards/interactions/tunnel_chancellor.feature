Feature: Tunnel "discarded" to Chancellor shouldn't trigger

  Background:
    Given I am a player in a standard game with Tunnel, Chancellor

  Scenario:
    Given my hand contains Chancellor
      And my deck contains Tunnel, Estate x3, Tunnel, Copper x3, Tunnel
    When I play Chancellor
    And I choose the option Discard deck
      Then I should have moved Tunnel, Estate x3, Tunnel, Copper x3, Tunnel from deck to discard
    When the game checks actions
      Then it should be my Buy phase
