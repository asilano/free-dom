# Action (cost: 3) — +1 Card. +1 Action. Look through your discard pile. You may put a card from it onto your deck.
Feature: Harbinger
  Background:
    Given I am in a 3 player game
    And my hand contains Harbinger, Estate, Copper x2, Silver

  Scenario: Playing Harbinger
    Given my deck contains Artisan, Copper
    And my discard contains Estate, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Harbinger in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Choose a card to return from your discard'
    When I choose Silver in my discard
    Then cards should move as follows:
      Then I should move Silver from my discard to my deck
      And these card moves should happen

  Scenario: Playing Harbinger when discard is empty
    Given my deck contains Artisan, Copper
    And my discard contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Harbinger in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Choose a card to return from your discard'
    When I choose 'Return nothing' in my discard
    Then cards should not move

  Scenario: Playing Harbinger when deck is empty, but discard isn't
    Given my deck contains nothing
    And my discard contains Estate, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Harbinger in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Choose a card to return from your discard'
    When I choose 'Return nothing' in my discard
    Then cards should not move

  Scenario: Playing Harbinger when deck and discard are empty
    Given my deck contains nothing
    And my discard contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Harbinger in my hand
    Then cards should not move
    And I should have 1 action
    And I should need to 'Choose a card to return from your discard'
    When I choose 'Return nothing' in my discard
    Then cards should not move

  Scenario: Playing Harbinger and then picking nothing
    Given my deck contains Artisan, Copper
    And my discard contains Estate, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Harbinger in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Choose a card to return from your discard'
    When I choose 'Return nothing' in my discard
    Then cards should not move
