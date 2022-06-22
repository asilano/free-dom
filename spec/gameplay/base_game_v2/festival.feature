# Action (cost: 5) - +2 Actions. +1 Buy. +2 Cash
Feature: Festival
  Background:
    Given I am in a 3 player game
    And my hand contains Festival x2, Estate, Copper, Silver

  Scenario: Playing Festival, twice
    Then I should need to 'Play an Action, or pass'
    When I choose Festival in my hand
    Then I should have 2 actions
    And I should have 2 buys
    And I should have $2
    And I should need to 'Play an Action, or pass'
    When I choose Festival in my hand
    Then I should have 3 actions
    And I should have 3 buys
    And I should have $4
