# Action (cost: 4) - +1 Card. +2 Actions. Trash a card from your hand. If it's a Victory card, gain a Curse.
Feature: Hideout
  Background:
    Given I am in a 3 player game
    And my hand contains Hideout, Market, Cargo Ship, Gold, Estate
    And the kingdom choice contains Hideout
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Hideout, trash a non-Victory
    When I choose Hideout in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 2 actions
    And I should need to "Choose a card to trash"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should trash Market from my hand
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: Playing Hideout, trash a Victory
    When I choose Hideout in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 2 actions
    And I should need to "Choose a card to trash"
    When I choose Estate in my hand
    Then cards should move as follows:
      Then I should trash Estate from my hand
      And I should gain Curse
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: Playing Hideout, trash a Victory but no Curses remain
  Given the Curse pile contains nothing
    When I choose Hideout in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 2 actions
    And I should need to "Choose a card to trash"
    When I choose Estate in my hand
    Then cards should move as follows:
      Then I should trash Estate from my hand
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: Playing Hideout, nothing to trash (requires empty deck)
    Given my hand contains Hideout
    And my deck contains nothing
    Then I should need to "Play an Action, or pass"
    When I choose Hideout in my hand
    Then I should need to "Choose a card to trash"
    When I choose "Trash nothing" in my hand
    Then I should need to "Play an Action, or pass"
