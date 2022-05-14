# Silos (cost: 4) - At the start of your turn, discard any number of Coppers, revealed, and draw that many cards.
Feature: Silos
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the Silos project
    Then I should need to "Play an Action, or pass"

  Scenario: Silos occurring
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Silos project
    And my deck contains Copper x3, Estate, Curse
    When I pass through to my next turn
    Then I should need to "Discard any number of Coppers"
    When I choose Copper x2 in my hand
    Then cards should move as follows:
      Then I should discard Copper x2 from my hand
      And I should draw 2 cards
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: Silos occurring when no Coppers in hand
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the Silos project
    And my deck contains Silver x3, Estate, Curse
    When I pass through to my next turn
    Then I should need to "Discard any number of Coppers"
    When I choose nothing in my hand
    Then cards should not move
    And I should need to "Play an Action, or pass"
