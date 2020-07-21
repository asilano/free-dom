# Action (cost: 5) - +2 Cards. +1 Action.
Feature: Laboratory
  Background:
    Given I am in a 3 player game
    And my hand contains Laboratory, Estate, Copper, Silver

  Scenario: Playing Laboratory
    And my deck contains Gold, Cellar
    Then I should need to 'Play an Action, or pass'
    When I choose Laboratory in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should have 1 action

  Scenario: Playing Laboratory, insufficient cards
    And my deck contains Gold
    Then I should need to 'Play an Action, or pass'
    When I choose Laboratory in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action

  Scenario: Playing Laboratory, no cards
    And my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Laboratory in my hand
    Then cards should not move
    And I should have 1 action
