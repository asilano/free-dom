Feature: Coffers
  Coffers, granted in a variety of ways by a number of cards, can be "spent" _at any point_ in the Buy phase
  to grant +1 Cash per Coffers spent. (In the future, Coffers may be spendable at _any_ time.)

  "At any point" is tricky - if the player has Coffers, we ask to spend them whenever we ask anything else. There
  may be situations where we want to ask more frequently, but those will be handled case-by-case.

  Background:
    Given I am in a 3 player game

  Scenario: Not asked to spend Coffers when I have none
    Given I have 0 Coffers
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    And I should not need to "Spend Coffers"

  Scenario: Have 1 Coffers, spend 1 Coffers, get 1 Cash (when stack empty)
    Given I have 1 Coffers
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    And I should need to "Spend Coffers"
    When I spend 1 Coffers
    Then I should have 1 cash
    And I should have 0 Coffers
    And I should need to "Play Treasures, or pass"
    And I should not need to "Spend Coffers"

  Scenario: Have 3 Coffers, spend 2 Coffers, then spend remaining Coffers (when stack empty)
    Given I have 3 Coffers
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    And I should need to "Spend Coffers"
    When I spend 2 Coffers
    Then I should have 2 cash
    And I should have 1 Coffers
    And I should need to "Play Treasures, or pass"
    And I should need to "Spend Coffers"
    When I spend 1 Coffers
    Then I should have 3 cash
    And I should have 0 Coffers
    And I should need to "Play Treasures, or pass"
    And I should not need to "Spend Coffers"

  Scenario: Have 3 Coffers, spend 2 Coffers, then spend remaining Coffers next turn (when stack empty)
    Given I have 3 Coffers
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    And I should need to "Spend Coffers"
    When I spend 2 Coffers
    Then I should have 2 cash
    And I should have 1 Coffers
    And I should need to "Play Treasures, or pass"
    And I should need to "Spend Coffers"
    When I pass through to my next turn
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    And I should need to "Spend Coffers"
    When I spend 1 Coffers
    Then I should have 1 cash
    And I should have 0 Coffers
    And I should need to "Play Treasures, or pass"
    And I should not need to "Spend Coffers"

  Scenario: Have 3 Coffers, spend 1 Coffers (stack empty), then play treasure and spend another Coffers during resolution
    Given pending any special treasure

  Scenario: Spend Coffers specifically when Venture flips up a Diadem
    Given pending Venture and Diadem
