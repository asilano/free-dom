# Action (cost: 2) — +1 Action. Discard any number of cards, then draw that many.
Feature: Cellar
  Background:
    Given I am in a 3 player game
    And my hand contains Cellar, Estate, Copper x2, Silver
    And my deck contains Artisan, Gold, Village

  Scenario: Play Cellar, discard lots
    Then I should need to 'Play an Action, or pass'
    When I choose Cellar in my hand
    Then I should need to 'Discard any number of cards'
    When I choose Estate, Copper, Silver in my hand
    Then cards should move as follows:
      Then I should discard Estate, Copper, Silver from my hand
      And I should draw 3 cards
      And these card moves should happen
    And I should need to 'Play an Action, or pass'

  Scenario: Play Cellar, discard one
    Then I should need to 'Play an Action, or pass'
    When I choose Cellar in my hand
    Then I should need to 'Discard any number of cards'
    When I choose Estate in my hand
    Then cards should move as follows:
      Then I should discard Estate from my hand
      And I should draw 1 card
      And these card moves should happen
    And I should need to 'Play an Action, or pass'

  Scenario: Play Cellar, discard none
    Then I should need to 'Play an Action, or pass'
    When I choose Cellar in my hand
    Then I should need to 'Discard any number of cards'
    When I choose nothing in my hand
    Then cards should not move
    And I should need to 'Play an Action, or pass'

  Scenario: Play Cellar, discard more cards than can be drawn
    Then I should need to 'Play an Action, or pass'
    When I choose Cellar in my hand
    Then I should need to 'Discard any number of cards'
    When I choose Estate, Copper x2, Silver in my hand
    Then cards should move as follows:
      Then I should discard Estate, Copper x2, Silver from my hand
      And I should draw 4 cards
      And these card moves should happen
    And I should need to 'Play an Action, or pass'
