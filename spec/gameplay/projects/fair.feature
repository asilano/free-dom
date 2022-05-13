# Project (cost: 4) - At the start of your turn, +1 Buy.
Feature: Fair
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Fair project
    Then I should need to "Play an Action, or pass"

  Scenario: Fair occurring
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Fair project
    When I pass through to my next turn
    Then I should have 2 buys
