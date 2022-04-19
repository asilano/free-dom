Feature: Projects
  Projects can be purchased with a Buy for their cost; but only once per player

  Background:
    Given I am in a 3 player game
    And the kingdom choice contains the Cathedral project
    And the kingdom choice contains the City Gate project

  Scenario: Can buy Projects when I have enough cash
    Given my hand contains Gold x3, Estate x2
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    And I should be able to choose the Cathedral project
    And I should be able to choose the City Gate project

  Scenario: Can't buy Projects when I don't have enough cash
    Given my hand contains Silver x3, Estate x2
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    And I should not be able to choose the Cathedral project
    And I should not be able to choose the City Gate project

  Scenario: Can't buy Projects when I already have them
    Given my hand contains Gold x3, Estate x2
    And I have the Cathedral project
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    And I should not be able to choose the Cathedral project
