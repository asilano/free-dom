# Type (cost: n) - +1 Action
# Reveal your hand. If the revealed cards all have different names, +3 Cards. Otherwise, +1 Card.
Feature: Menagerie
  Background:
    Given I am in a 3 player game
    And my hand contains Menagerie, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Menagerie
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Menagerie, duplicates in hand
    Given my hand contains Menagerie, Market, Market, Gold, Village
    When I choose Menagerie in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to "Play an Action, or pass"

  Scenario: Playing Menagerie, unique cards in hand
    Given my hand contains Menagerie, Market, Copper, Gold, Village
    When I choose Menagerie in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should have 1 action
    And I should need to "Play an Action, or pass"

  Scenario: Playing Menagerie, second Menagerie in hand is still unique
    Given my hand contains Menagerie x2, Copper, Gold, Village
    When I choose Menagerie in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should have 1 action
    And I should need to "Play an Action, or pass"

  Scenario: Playing Menagerie, nothing in hand
    Given my hand contains Menagerie
    When I choose Menagerie in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should have 1 action
    And I should need to "Play an Action, or pass"
