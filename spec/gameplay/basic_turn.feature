Feature: Basic turn
  Background:
    Given I am in a 3 player game

  Scenario: Basic turn flow
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose nothing in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"

  Scenario: Play nothing, can buy
    Given the kingdom contains Market, Workshop
      And my hand contains Estate x2, Copper x3
    Then my hand should contain Estate x2, Copper x3
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose everything in my hand
    Then my hand should contain Estate x2
    And I should have Copper x3 in play
    And I should need to "Buy a card, or pass"
    And I should be able to choose the Copper, Estate, Silver, Workshop piles
    And I should not be able to choose the Market, Gold, Province piles
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Play some treasures, can buy
    Given the kingdom contains Market, Workshop, Cellar
      And my hand contains Estate x2, Copper x3
    Then my hand should contain Estate x2, Copper x3
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Copper, Copper in my hand
    Then my hand should contain Copper, Estate x2
    And I should have Copper x2 in play
    And I should need to "Play Treasures, or pass"
    When I choose nothing in my hand
    Then my hand should contain Copper, Estate x2
    And I should have Copper x2 in play
    And I should need to "Buy a card, or pass"
    And I should be able to choose the Copper, Estate, Cellar piles
    And I should not be able to choose the Silver, Workshop, Market, Gold, Province piles
    When I choose Cellar in the supply
    Then cards should move as follows:
      Then I should gain Cellar
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen
