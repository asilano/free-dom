# Project (cost: 3) - At the end of your Buy phase, you may pay $1 for +1 Coffers.
Feature: Pageant
  Background:
    Given I am in a 3 player game
    And my hand contains Copper x2, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Pageant project
    And I have the Pageant project
    Then I should need to "Play an Action, or pass"

  Scenario: Pageant project triggers after buying nothing
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Copper in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then I should need to "Choose whether to spend $1 for +1 Coffers"
    When I choose the option "Spend $1"
    Then I should have 1 Coffers

  Scenario: Pageant project triggers after buying something, and only at end of Buy phase
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver
      And these card moves should happen
    And I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then I should need to "Choose whether to spend $1 for +1 Coffers"
    When I choose the option "Spend $1"
    Then I should have 1 Coffers

  Scenario: Pageant project triggers, but decline
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Copper in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then I should need to "Choose whether to spend $1 for +1 Coffers"
    When I choose the option "Decline"
    Then I should have 0 Coffers

  Scenario: Pageant project doesn't trigger if no cash remaining
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen
