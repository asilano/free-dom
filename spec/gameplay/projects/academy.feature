# Project (cost: 5) - When you gain an Action card, +1 Villager.
Feature: Academy
  Background:
    Given I am in a 3 player game
    And my hand contains Workshop, Cargo Ship, Gold, Village
    And the kingdom choice contains the Academy project
    Then I should need to "Play an Action, or pass"

  Scenario: Academy triggers from Buy
    When I choose "Leave Action Phase" in my hand
    Given I have the Academy project
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver
      And I should discard everything from in play
      And I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And I should have 1 Villager

  Scenario: Academy triggers from non-Buy Gain
    Then I should need to "Play an Action, or pass"
    Given I have the Academy project
    When I choose Workshop in my hand
    Then I should need to "Choose a card to gain"
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver
      And these card moves should happen
    And I should have 1 Villager
