# Action (cost: 2) - +1 Card. +1 Action. You may discard a card for +1 Action. You may discard a card for +1 Buy.
Feature: Hamlet
  Background:
    Given I am in a 3 player game
    And my hand contains Hamlet, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Hamlet
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Hamlet; discard neither
    When I choose Hamlet in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Discard a card to get an Action"
    When I choose "Discard nothing (for Action)" in my hand
    Then cards should not move
    And I should need to "Discard a card to get a Buy"
    When I choose "Discard nothing (for Buy)" in my hand
    Then cards should not move
    And I should have 1 action
    And I should have 1 buy
    And I should need to "Play an Action, or pass"

  Scenario: Playing Hamlet; discard for Action
    When I choose Hamlet in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to "Discard a card to get an Action"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should discard Market from my hand
      And these card moves should happen
    And I should have 2 actions
    And I should need to "Discard a card to get a Buy"
    When I choose "Discard nothing (for Buy)" in my hand
    Then cards should not move
    And I should have 1 buy
    And I should need to "Play an Action, or pass"

  Scenario: Playing Hamlet; discard for Buy
    When I choose Hamlet in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Discard a card to get an Action"
    When I choose "Discard nothing (for Action)" in my hand
    Then cards should not move
    And I should need to "Discard a card to get a Buy"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should discard Market from my hand
      And these card moves should happen
    And I should have 1 action
    And I should have 2 buys
    And I should need to "Play an Action, or pass"

  Scenario: Playing Hamlet; discard for both
    When I choose Hamlet in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to "Discard a card to get an Action"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should discard Market from my hand
      And these card moves should happen
    And I should have 2 actions
    And I should need to "Discard a card to get a Buy"
    When I choose Gold in my hand
    Then cards should move as follows:
      Then I should discard Gold from my hand
      And these card moves should happen
    And I should have 2 actions
    And I should have 2 buys
    And I should need to "Play an Action, or pass"
