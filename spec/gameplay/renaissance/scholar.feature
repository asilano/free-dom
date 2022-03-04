# Action (cost: 5) - Discard your hand. +7 Cards.
Feature: Scholar
  Background:
    Given I am in a 3 player game
    And my hand contains Scholar, Market, Cargo Ship, Gold, Village
    And my deck contains Copper x10
    And the kingdom choice contains Scholar
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Scholar
    When I choose Scholar in my hand
    Then cards should move as follows:
      Then I should discard everything in my hand
      And I should draw 7 cards
    And these card moves should happen
    And I should need to "Play Treasures, or pass"
