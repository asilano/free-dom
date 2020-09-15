# Action (cost: 4) - +1 Card. +1 Action. +1 Cash. Discard a card per empty Supply pile.
Feature: Poacher
  Background:
    Given I am in a 3 player game
    And my hand contains Poacher, Copper x2, Silver x2

  Scenario: Playing Poacher, no empty supply piles
    Then I should need to 'Play an Action, or pass'
    When I choose Poacher in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 cash
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Poacher, one empty pile
    When the Estate pile is empty
    Then I should need to 'Play an Action, or pass'
    When I choose Poacher in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 cash
    And I should need to 'Discard 1 card'
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should discard Copper from my hand
      And these card moves should happen
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Poacher, two empty piles
    When the Estate pile is empty
      And the Silver pile is empty
    Then I should need to 'Play an Action, or pass'
    When I choose Poacher in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 cash
    And I should need to 'Discard 2 cards'
    When I choose Copper, Silver in my hand
    Then cards should move as follows:
      Then I should discard Copper, Silver from my hand
      And these card moves should happen
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Poacher, can't draw
    Given my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Poacher in my hand
    Then cards should not move
    And I should have 1 cash
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Poacher, two empty piles, can't discard that many
    When the Estate pile is empty
      And the Silver pile is empty
      And my hand contains Poacher
      And my deck contains Gold
    Then I should need to 'Play an Action, or pass'
    When I choose Poacher in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 cash
    And I should need to 'Discard 1 card'
    When I choose Gold in my hand
    Then cards should move as follows:
      Then I should discard Gold from my hand
      And these card moves should happen
    And I should need to 'Play an Action, or pass'
