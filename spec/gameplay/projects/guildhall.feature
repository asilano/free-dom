# Project (cost: 5) - When you gain an Treasure card, +1 Coffers.
Feature: Guildhall
  Background:
    Given I am in a 3 player game
    And my hand contains Workshop, Cargo Ship, Gold, Village
    And the kingdom choice contains Village
    And the kingdom choice contains the Guildhall project
    Then I should need to "Play an Action, or pass"

  Scenario: Guildhall triggers from Buy
    When I choose "Leave Action Phase" in my hand
    Given I have the Guildhall project
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
    And I should have 1 Coffers

  Scenario: Guildhall does not trigger from gain of non-Action
    When I choose "Leave Action Phase" in my hand
    Given I have the Guildhall project
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Village in the supply
    Then cards should move as follows:
      Then I should gain Village
      And I should discard everything from in play
      And I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And I should have 0 Coffers

  Scenario: Guildhall triggers from non-Buy Gain
    Then I should need to "Play an Action, or pass"
    Given I have the Guildhall project
    When I choose Workshop in my hand
    Then I should need to "Choose a card to gain"
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver
      And these card moves should happen
    And I should have 1 Coffers
