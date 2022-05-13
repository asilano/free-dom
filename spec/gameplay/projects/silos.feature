# Silos (cost: 4) - Card text
Feature: Silos
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Silos project
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Silos
    Given pending
