# Action (cost: 3) - +1 Card. +2 Actions.
Feature: Village
  Background:
    Given I am in a 3 player game
    And my hand contains Village, Village, Copper, Silver

  Scenario: Playing Village
    And my deck contains Gold, Cellar
    Then I should need to 'Play an Action, or pass'
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 2 actions
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Village twice
    And my deck contains Gold, Cellar
    Then I should need to 'Play an Action, or pass'
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to 'Play an Action, or pass'
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 3 actions

  Scenario: Playing Village, no cards
    And my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Village in my hand
    Then cards should not move
    And I should have 2 actions
