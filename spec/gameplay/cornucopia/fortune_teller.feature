# Action (cost: 3) - +$2
# Each other player reveals cards from the top of their deck until they reveal a
# Victory card or a Curse. They put it on top and discard the rest.
Feature: Fortune Teller
  Background:
    Given I am in a 2 player game
    And my hand contains Fortune Teller, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Fortune Teller, Patron
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Fortune Teller, hit Victory
    Given Belle's deck contains Copper, Village, Gold, Estate, Silver
    When I choose Fortune Teller in my hand
    Then cards should move as follows:
      Then Belle should discard Copper, Village, Gold from her deck
      And these card moves should happen
    And I should have $2
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Fortune Teller, hit Curse as last card in deck
    Given Belle's deck contains Copper, Village, Gold, Curse
      And Belle's discard contains Copper, Estate
    When I choose Fortune Teller in my hand
    Then cards should move as follows:
      Then Belle should discard Copper, Village, Gold from her deck
      And these card moves should happen
    And I should have $2
    And I should need to "Play Treasures, or pass"

  Scenario: Victim's deck first contains a dual-type Victory
    Given pending "dual-type Victory card"

  Scenario: Victim's deck contains no targets until after shuffle
    Given Belle's deck contains Copper, Village, Gold
      And Belle's discard contains Copper, Curse, Estate
    When I choose Fortune Teller in my hand
    Then cards should move as follows:
      Then Belle should shuffle her discards
      And Belle should discard Copper, Village, Gold, Copper from her deck
      And these card moves should happen
    And I should have $2
    And I should need to "Play Treasures, or pass"

  Scenario: Victim's deck contains no targets
    Given Belle's deck contains Copper, Village, Gold
      And Belle's discard contains Copper, Market, Witch
    When I choose Fortune Teller in my hand
    Then cards should move as follows:
      Then Belle should shuffle her discards
      And Belle should discard Copper, Village, Gold, Copper, Market, Witch from her deck
      And these card moves should happen
    And I should have $2
    And I should need to "Play Treasures, or pass"

  Scenario: Victim's deck has an on-reveal trigger before the first Victory
    Given Belle's deck contains Copper, Patron, Gold, Estate, Silver
    When I choose Fortune Teller in my hand
    Then cards should move as follows:
      Then Belle should discard Copper, Patron, Gold from her deck
      And these card moves should happen
    And Belle should have 1 Coffers
    And I should have $2
    And I should need to "Play Treasures, or pass"
