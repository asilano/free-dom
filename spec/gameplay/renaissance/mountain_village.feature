# Action (cost: 4) - +2 Actions. Look through your discard pile and put a card from it into your hand; if you can't, +1 Card.
Feature: Mountain Village
  Background:
    Given I am in a 3 player game
    And my hand contains Mountain Village, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Mountain Village
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Mountain Village
    Given my discard contains Copper, Silver, Workshop
    When I choose Mountain Village in my hand
    Then I should have 2 actions
    And I should need to "Choose a card to return from your discard"
    And I should be able to choose Copper, Silver, Workshop in my discard
    When I choose Silver in my discard
    Then cards should move as follows:
      Then I should move Silver from my discard to my hand
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: Playing Mountain Village, nothing in discard
    Given my discard contains nothing
    When I choose Mountain Village in my hand
    Then I should have 2 actions
    And I should need to "Choose a card to return from your discard"
    When I choose "Return nothing" in my discard
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Play an Action, or pass"
