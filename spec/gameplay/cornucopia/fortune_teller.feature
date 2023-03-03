# Action (cost: 3) - +$2
# Each other player reveals cards from the top of their deck until they reveal a
# Victory card or a Curse. They put it on top and discard the rest.
Feature: Fortune Teller
  Background:
    Given I am in a 2 player game
    And my hand contains Fortune Teller, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Fortune Teller
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Fortune Teller, hit Victory
    Given Belle's deck contains Copper, Village, Gold, Estate, Silver
    When I choose Fortune Teller in my hand
    Then cards should move as follows:
      Then Belle should discard Copper, Village, Gold from her deck
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Fortune Teller, hit Curse
    Given Belle's deck contains Copper, Village, Gold, Curse, Silver
      And pending

  Scenario: Victim's deck first contains a dual-type Victory
    Given pending

  Scenario: Victim's deck contains no targets until after shuffle
    Given pending

  Scenario: Victim's deck contains no targets
    Given pending

  Scenario: Victim's deck has an on-reveal trigger before the first Victory
    Given pending