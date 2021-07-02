# Treasure (cost: 2) -+1 Coffers. +1 Buy. When you gain this, you may trash a Copper from your hand.
Feature: Ducat
  Background:
    Given I am in a 3 player game
    And my hand contains Ducat, Estate, Estate, Copper, Silver
    And the kingdom choice contains Ducat

  Scenario: Play Ducat, spend Coffer immediately
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 1 coffers
    And I should have 2 buys
    And I should have 0 cash
    When I spend 1 Coffers
    Then I should have 1 cash
    And I should have 0 coffers

  Scenario: Play two Ducats, spend both immediately
    Given pending

  Scenario: Play Ducat, save Coffer, spend it next turn
    Given pending

  Scenario: Play two Ducats, spend one Coffer
    Given pending

  Scenario: Buy Ducat, trash Copper
    Given pending

  Scenario: Buy Ducat, decline to trash Copper
    Given pending

  Scenario: Buy Ducat, not holding a Copper
    Given pending
