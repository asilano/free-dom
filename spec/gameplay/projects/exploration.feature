# Project (cost: 4) - At the end of your Buy phase, if you didn't buy any cards during it, +1 Coffers and +1 Villager.
Feature: Exploration
  Background:
    Given I am in a 3 player game
    And my hand contains Copper x2, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Exploration project
    Then I should need to "Play an Action, or pass"

  Scenario: Exploration triggers when owned and nothing bought
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Exploration project
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And I should have 1 Coffers
    And I should have 1 Villager
    And Belle should need to "Play an Action, or pass"

  Scenario: Exploration does nothing when owned but card bought
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Exploration project
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Copper in the supply
    Then cards should move as follows:
      Then I should gain Copper
      And I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And I should have 0 Coffers
    And I should have 0 Villagers
    And Belle should need to "Play an Action, or pass"

  Scenario: Exploration does nothing when not owned and nothing bought
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And I should have 0 Coffers
    And I should have 0 Villager
    And Belle should need to "Play an Action, or pass"

  Scenario: Exploration works if a card bought last turn
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Exploration project
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Copper in the supply
    Then cards should move as follows:
      Then I should gain Copper
      And I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And I should have 0 Coffers
    And I should have 0 Villagers
    And Belle should need to "Play an Action, or pass"
    When Belle passes through to my next turn
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And I should have 1 Coffers
    And I should have 1 Villager
    And Belle should need to "Play an Action, or pass"

  Scenario: Exploration still works if Exploration is only thing bought
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Copper in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose the Exploration project
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from in play
      And I should draw 5 cards
      And these card moves should happen
    And I should have 1 Coffers
    And I should have 1 Villagers
    And Belle should need to "Play an Action, or pass"

  Scenario: Exploration still works if one Buy phase if something bought in a previous Buy phase
    Given pending Villa or Cavalry

  Scenario: Exploration still works if something bought earlier, not in a Buy phase
    Given pending Black Market
