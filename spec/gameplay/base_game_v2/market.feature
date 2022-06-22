# Action (cost: 5) - +1 Card, +1 Action, +1 Buy, +1 Cash
Feature: Market
  Background:
    Given I am in a 3 player game
    And my hand contains Market x2, Estate, Copper, Silver

  Scenario: Playing Market, twice
    And my deck contains Gold, Cellar
    Then I should need to 'Play an Action, or pass'
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should draw 1 cards
      And these card moves should happen
    And I should have 1 action
    And I should have 2 buys
    And I should have $1
    And I should need to 'Play an Action, or pass'
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should draw 1 cards
      And these card moves should happen
    And I should have 1 action
    And I should have 3 buys
    And I should have $2

  Scenario: Playing Market, no cards
    And my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Market in my hand
    Then cards should not move
    And I should have 1 action
    And I should have 2 buys
    And I should have $1
