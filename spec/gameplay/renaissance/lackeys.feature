# Action (cost: 2) - +2 Cards. When you gain this, +2 Villagers.
Feature: Lackeys
  Background:
    Given I am in a 3 player game
    And my hand contains Lackeys, Border Guard, Estate, Copper, Silver
    And the kingdom choice contains Lackeys

    Scenario: Playing Lackeys
    And my deck contains Gold, Cellar, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Lackeys in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Lackeys, insufficient cards
    And my deck contains Gold
    Then I should need to 'Play an Action, or pass'
    When I choose Lackeys in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Lackeys, no cards
    And my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Lackeys in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'

  Scenario: Get Villagers on gain
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    And I should need to "Buy a card, or pass"
    When I choose Lackeys in the supply
    Then cards should move as follows:
      Then I should gain Lackeys
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen
    And I should have 2 Villagers
