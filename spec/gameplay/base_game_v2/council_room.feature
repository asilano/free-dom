# Action (cost: 5) — +4 Cards, +1 Buy. Discard any number of cards, then draw that many.
Feature: Council Room
  Background:
    Given I am in a 3 player game
    And my hand contains Council Room, Estate, Copper x2, Silver

  Scenario: Play Council Room normally
    When my deck contains Artisan, Gold, Village, Laboratory, Festival
    And Belle's deck contains Copper, Curse
    And Chas's deck contains Estate, Duchy
    Then I should need to 'Play an Action, or pass'
    When I choose Council Room in my hand
    Then cards should move as follows:
      Then I should draw 4 cards
      And Belle should draw 1 card
      And Chas should draw 1 card
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Play Council Room when player can't draw all 4
    When my deck contains Artisan, Gold
    And Belle's deck contains Copper, Curse
    And Chas's deck contains Estate, Duchy
    Then I should need to 'Play an Action, or pass'
    When I choose Council Room in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And Belle should draw 1 card
      And Chas should draw 1 card
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Play Council Room when opponent can't draw
    When my deck contains Artisan, Gold, Village, Laboratory, Festival
    And Belle's deck contains Copper, Curse
    And Chas's deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Council Room in my hand
    Then cards should move as follows:
      Then I should draw 4 cards
      And Belle should draw 1 card
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
