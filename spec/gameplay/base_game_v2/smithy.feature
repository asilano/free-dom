# Action (cost: 4) - +3 Cards
Feature: Smithy
  Background:
    Given I am in a 3 player game
    And my hand contains Smithy, Estate, Copper, Silver

  Scenario: Playing Smithy
    And my deck contains Gold, Cellar, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Smithy in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Smithy, insufficient cards
    And my deck contains Gold
    Then I should need to 'Play an Action, or pass'
    When I choose Smithy in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Smithy, no cards
    And my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Smithy in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'
