Feature: Villagers
  Villagers, granted in a variety of ways by a number of cards, can be "spent" _at any point_ in the Action phase
  to grant +1 Action per Villager spent.

  "At any point" is tricky - if the player has Villagers, we ask to spend them whenever we ask anything else. There
  may be situations where we want to ask more frequently, but those will be handled cas-by-case.

  Background:
    Given I am in a 3 player game

  Scenario: Not asked to spend Villagers when I have none
    Given I have 0 Villagers
    Then I should need to "Play an Action, or pass"
    And I should not need to "Spend Villagers"

  Scenario: Have 1 Villager, spend 1 Villager, get 1 Action (when stack empty)
    Given I have 1 Villager
    Then I should need to "Play an Action, or pass"
    And I should need to "Spend Villagers"
    When I spend 1 Villager
    Then I should have 2 actions
    And I should have 0 Villagers
    And I should need to "Play an Action, or pass"
    And I should not need to "Spend Villagers"

  Scenario: Have 3 Villagers, spend 2 Villagers, then spend remaining Villager (when stack empty)
    Given I have 3 Villagers
    Then I should need to "Play an Action, or pass"
    And I should need to "Spend Villagers"
    When I spend 2 Villagers
    Then I should have 3 actions
    And I should have 1 Villager
    And I should need to "Play an Action, or pass"
    And I should need to "Spend Villagers"
    When I spend 1 Villager
    Then I should have 4 actions
    And I should have 0 Villagers
    And I should need to "Play an Action, or pass"
    And I should not need to "Spend Villagers"

  Scenario: Have 3 Villagers, spend 1 Villager (stack empty), then play action and spend another Villager during resolution
    Given I have 3 Villagers
    And my hand contains Moneylender, Copper
    Then I should need to "Play an Action, or pass"
    And I should need to "Spend Villagers"
    When I spend 1 Villagers
    Then I should have 2 actions
    And I should have 2 Villager
    And I should need to "Play an Action, or pass"
    And I should need to "Spend Villagers"
    When I choose Moneylender in my hand
    Then I should need to "Choose whether to trash a Copper"
    And I should need to "Spend Villagers"
    When I spend 1 Villager
    Then I should have 2 actions
    And I should have 1 Villager
    And I should need to "Choose whether to trash a Copper"
    And I should need to "Spend Villagers"
    When I choose the option "Don't trash"
    Then I should need to "Play an Action, or pass"
    And I should need to "Spend Villagers"
