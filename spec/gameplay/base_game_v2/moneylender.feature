# Action (cost: 4) - You may trash a Copper from your hand for +3 Cash.
Feature: Moneylender
  Background:
    Given I am in a 3 player game
    And my hand contains Moneylender, Copper x2, Silver x2

  Scenario: Playing Moneylender, choose to trash
    Then I should need to 'Play an Action, or pass'
    When I choose Moneylender in my hand
    Then I should need to 'Choose whether to trash a Copper'
    When I choose the option 'Trash'
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should have 3 cash

  Scenario: Playing Moneylender, choose not to trash
    Then I should need to 'Play an Action, or pass'
    When I choose Moneylender in my hand
    Then I should need to 'Choose whether to trash a Copper'
    When I choose the option "Don't trash"
    Then cards should not move
    And I should have 0 cash

  Scenario: Playing Moneylender, can't trash
    And my hand contains Moneylender, Silver x2
    Then I should need to 'Play an Action, or pass'
    When I choose Moneylender in my hand
    Then I should need to 'Choose whether to trash a Copper'
    When I choose the option "Don't trash"
    Then cards should not move
    And I should have 0 cash
