# Action (cost: 3) — +1 Card. +1 Action. The first time you play a Silver this turn, +1 Cash.
Feature: Merchant
  Background:
    Given I am in a 3 player game
    And my hand contains Merchant x2, Copper, Silver x2
    And my deck contains Silver x2

  Scenario: Playing one Merchant, then a Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have $3

  Scenario: Merchant affects only the first Silver played
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have $3
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have $5

  Scenario: Merchant does not affect and is not affected by non-Silver treasures
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Copper in my hand
    Then I should have $1
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have $4

  Scenario: Multiple Merchants affect the first Silver played
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have $4
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have $6

  Scenario: Merchant should not affect next turn
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    When I pass through to my next turn
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have $2
