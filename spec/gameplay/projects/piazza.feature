# Project (cost: 5) - At the start of your turn, reveal the top card of your deck. If it's an Action, play it.
Feature: Piazza
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Patron
    And the kingdom choice contains the Piazza project
    Then I should need to "Play an Action, or pass"

  Scenario: Piazza triggers, hitting action
    Given my deck contains Copper x5, Festival
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Piazza project
    When I pass through to just before my next turn
      Then I should move Festival from my deck to in play
      And these card moves should happen
    And I should have 3 actions
    And I should have 2 buys
    And I should have $2

  Scenario: Piazza triggers, hitting Throne Room
    Given my deck contains Copper x4, Festival, Throne Room
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Piazza project
    When I pass through to just before my next turn
      Then I should move Throne Room from my deck to in play
      And these card moves should happen
    Then I should need to 'Choose an Action to play twice'
    When I choose Festival in my hand
    Then cards should move as follows:
      Then I should move Festival from my hand to in play
      And these card moves should happen
    And I should have 5 actions
    And I should have 3 buys
    And I should have $4

  Scenario: Piazza triggers, hitting Patron
    Given my deck contains Copper x5, Patron
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Piazza project
    When I pass through to just before my next turn
      Then I should move Patron from my deck to in play
      And these card moves should happen
    And I should have 1 Villager
    And I should have 1 Coffers
    And I should have $2

  Scenario: Piazza triggers, not hitting action
    Given my deck contains Copper x6
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Piazza project
    When I pass through to just before my next turn
      Then I should reveal 1 card from my deck
      And I should unreveal Copper from my deck
      And these card moves should happen
    And I should need to "Play an Action, or pass"
