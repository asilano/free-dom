# Project (cost: 6) - At the start of your turn, +1 Action.
Feature: Barracks
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Barracks project
    Then I should need to "Play an Action, or pass"

  Scenario: Barracks triggers
    Given I have the Barracks project
    When I pass through to my next turn
    Then I should need to "Play an Action, or pass"
    And I should have 2 actions
