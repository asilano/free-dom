# Project (cost: 3) - At the start of your turn, trash a card from your hand.
Feature: Cathedral
  Background:
    Given I am in a 3 player game
    And my hand contains Copper, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Cathedral project
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Cathedral
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Cathedral project
    And my deck contains Copper, Estate x2, Curse x2
    When I pass through to me next turn
    Then I should need to "Choose a card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Play an Action, or pass"
