# Action (cost: 2) - Trash up to 4 cards from your hand.
Feature: Chapel
  Background:
    Given I am in a 3 player game
    And my hand contains Chapel, Estate, Copper x2, Silver, Village

  Scenario: Play Chapel, trash lots
    Then I should need to 'Play an Action, or pass'
    When I choose Chapel in my hand
    Then I should need to 'Trash up to 4 cards'
    When I choose Estate, Copper, Silver in my hand
    Then cards should move as follows:
      Then I should trash Estate, Copper, Silver from my hand
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Play Chapel, trash one
    Then I should need to 'Play an Action, or pass'
    When I choose Chapel in my hand
    Then I should need to 'Trash up to 4 cards'
    When I choose Silver in my hand
    Then cards should move as follows:
      Then I should trash Silver from my hand
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Play Chapel, trash none
    Then I should need to 'Play an Action, or pass'
    When I choose Chapel in my hand
    Then I should need to 'Trash up to 4 cards'
    When I choose nothing in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'
