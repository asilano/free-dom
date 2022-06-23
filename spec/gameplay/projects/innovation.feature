# Project (cost: 6) - The first time you gain an Action card during each of your turns, you may play it.
Feature: Innovation
  Background:
    Given I am in a 3 player game
    And my hand contains Copper, Cargo Ship, Gold, Workshop, Throne Room
    And the kingdom choice contains Silk Merchant
    And the kingdom choice contains the Innovation project
    Then I should need to "Play an Action, or pass"

  Scenario: Innovation triggers on Buy, choose to play
    Given I have the Innovation project
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Copper in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Silk Merchant in the supply
    Then cards should move as follows:
      Then I should gain Silk Merchant
      And these card moves should happen
    Then I should need to "Choose whether to play Silk Merchant"
    When I choose the option "Play Silk Merchant"
    Then cards should move as follows:
      Then I should move Silk Merchant from my discard to in play
      And I should draw 2 cards
      And these card moves should happen
    And I should need to "Buy a card, or pass"
    And I should have 1 buy

  Scenario: Innovation triggers on non-Buy gain, choose to play
    Given I have the Innovation project
    When I choose Workshop in my hand
    Then I should need to "Choose a card to gain"
    When I choose Silk Merchant in the supply
    Then cards should move as follows:
      Then I should gain Silk Merchant
      And these card moves should happen
    Then I should need to "Choose whether to play Silk Merchant"
    When I choose the option "Play Silk Merchant"
    Then cards should move as follows:
      Then I should move Silk Merchant from my discard to in play
      And I should draw 2 cards
      And these card moves should happen
    And I should have 1 Coffers
    And I should have 1 Villagers
    And I should need to "Spend Villagers"
    And I should have 2 buys

  Scenario: Innovation triggers on non-Buy gain, choose not to play
    Given I have the Innovation project
    When I choose Workshop in my hand
    Then I should need to "Choose a card to gain"
    When I choose Silk Merchant in the supply
    Then cards should move as follows:
      Then I should gain Silk Merchant
      And these card moves should happen
    Then I should need to "Choose whether to play Silk Merchant"
    When I choose the option "Don't play Silk Merchant"
    Then cards should not move
    And I should need to "Leave the Action phase"
    And I should have 1 buy

  Scenario: Innovation triggers only on first gain
    Given I have the Innovation project
    When I choose Throne Room in my hand
    Then I should need to "Choose an Action to play twice"
    When I choose Workshop in my hand
    Then I should need to "Choose a card to gain"
    When I choose Silk Merchant in the supply
    Then cards should move as follows:
      Then I should gain Silk Merchant
      And these card moves should happen
    Then I should need to "Choose whether to play Silk Merchant"
    When I choose the option "Play Silk Merchant"
    Then cards should move as follows:
      Then I should move Silk Merchant from my discard to in play
      And I should draw 2 cards
      And these card moves should happen
    And I should have 2 buys
    Then I should need to "Choose a card to gain"
    When I choose Silk Merchant in the supply
    Then cards should move as follows:
      Then I should gain Silk Merchant
      And these card moves should happen
    And I should have 2 Coffers
    And I should have 2 Villagers
    And I should need to "Spend Villagers"
    And I should have 2 buys