# Project (cost: 4) - At the start of your turn, add a token here, or remove your tokens here for +1 Card each.
Feature: Sinister Plot
  Background:
    Given I am in a 3 player game
    And my hand contains Copper, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Sinister Plot project
    Then I should need to "Play an Action, or pass"

  Scenario: Sinister Plot triggers, add token
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Sinister Plot project
    When I pass through to my next turn
    Then I should need to "Choose whether to add a token or remove your tokens"
    When I choose the option "Add a token"
    Then there should be 1 of my tokens on the Sinister Plot project

  Scenario: Sinister Plot triggers, remove tokens
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Sinister Plot project
    And my deck contains Copper, Silver, Gold, Estate, Curse
    And there are 3 of my tokens on the Sinister Plot project
    When I pass through to my next turn
    Then I should need to "Choose whether to add a token or remove your tokens"
    When I choose the option "Remove your tokens"
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And there should be 0 of my tokens on the Sinister Plot project
