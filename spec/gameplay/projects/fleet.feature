# Project (cost: 5) - After the game ends, there's an extra round of turns just for players with this.
Feature: Fleet
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Fleet project
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Fleet
    Given I have the Fleet project
      And Chas has the Fleet project
      And the Province pile is empty
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And Chas should need to "Play an Action, or pass"
    When Chas chooses "Leave Action Phase" in his hand
    Then Chas should need to "Play Treasures, or pass"
    When Chas chooses 'Stop playing treasures' in his hand
    Then Chas should need to "Buy a card, or pass"
    When Chas chooses "Buy nothing" in the supply
    Then cards should move as follows:
      Then Chas should discard everything from his hand
      And Chas should draw 5 cards
      And these card moves should happen
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And the game should have ended

  Scenario: Playing Outpost during Fleet
    Given pending Outpost
