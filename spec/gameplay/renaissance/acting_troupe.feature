# Action (cost: 3) - +4 Villagers. Trash this
Feature: Acting Troupe
  Background:
    Given I am in a 3 player game
    And my hand contains Acting Troupe, Border Guard, Estate, Copper, Silver
    And the kingdom choice contains Acting Troupe

  Scenario: Playing Acting Troupe
    Then I should need to 'Play an Action, or pass'
    When I choose Acting Troupe in my hand
    Then I should have 4 Villagers
    And cards should move as follows:
      Then I should trash Acting Troupe from in play
    And I should need to "Spend Villagers"
