# Project (cost: 8) - The first time you play an Action card during each of your turns, replay it afterwards.
Feature: Citadel
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Citadel project
    And the kingdom choice contains the Capitalism project
    And I have the Citadel project
    Then I should need to "Play an Action, or pass"

  Scenario: Citadel doubles first action, but not second
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should have 2 actions
    And I should have 3 buys
    And I should have $2
    And I should need to "Play an Action, or pass"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 3 actions

  Scenario: Citadel doubles first action card, even if played as a treasure (via Capitalism)
    When I choose "Leave Action Phase" in my hand
    Given I have the Capitalism project
    Then I should need to "Play Treasures, or pass"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should move Market from my hand to in play
      Then I should draw 2 cards
      And these card moves should happen
    And I should have 3 buys
    And I should have $2
    And I should need to "Play Treasures, or pass"

  Scenario: If Citadel doesn't double anything one turn, it still doubles first action, but not second next turn
    When I pass through to my next turn
    Given my hand contains Market, Cargo Ship, Gold, Village
    Then I should need to "Play an Action, or pass"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should have 2 actions
    And I should have 3 buys
    And I should have $2
    And I should need to "Play an Action, or pass"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 3 actions

  Scenario: Citadel doubles first action if bought and moved back to action phase
    Given pending Villa

  Scenario: Citadel cannot double one-shot actions
    Given pending eg. Horse
