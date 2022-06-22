# Project (cost: 5) - When another player gains a Victory card, +1 Card.
Feature: Road Network
  Background:
    Given I am in a 3 player game
    And my hand contains Workshop, Cargo Ship, Gold, Village
    And the kingdom choice contains the Road Network project
    Then I should need to "Play an Action, or pass"

  Scenario: Road Network triggers on another player's buy
    Given Belle has the Road Network project
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Estate in the supply
    Then cards should move as follows:
      Then I should gain Estate
      And I should discard everything from in play
      And I should discard everything from my hand
      And I should draw 5 cards
      And Belle should draw 1 card
      And these card moves should happen

  Scenario: Road Network triggers on another player's non-buy gain
    Given Belle has the Road Network project
    When I choose Workshop in my hand
    Then I should need to "Choose a card to gain"
    When I choose Estate in the supply
    Then cards should move as follows:
      Then I should gain Estate
      And Belle should draw 1 card
      And these card moves should happen

  Scenario: Road Network does not trigger on non-Victory gain
    Given Belle has the Road Network project
    When I choose Workshop in my hand
    Then I should need to "Choose a card to gain"
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver
      And these card moves should happen

  Scenario: Road Network does not trigger on owner's gain
    Given I have the Road Network project
    When I choose Workshop in my hand
    Then I should need to "Choose a card to gain"
    When I choose Estate in the supply
    Then cards should move as follows:
      Then I should gain Estate
      And these card moves should happen
