# Action-Duration (cost: 4) - +1 Action
# Trash a card from your hand. Per 1 Cash it costs, set aside a card from your deck face down (on this). At the start of your next turn, put those cards into your hand.
Feature: Research
  Background:
    Given I am in a 3 player game
    And my hand contains Research, Market, Cargo Ship, Gold, Village
    And my deck contains Copper, Silver, Gold, Estate x5
    And the kingdom choice contains Research
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Research
    When I choose Research in my hand
    Then I should have 1 action
    And I should need to "Choose a card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And I should set aside Copper, Silver, Gold from my deck on my Research in play
      And these card moves should happen
    When I pass through to just before my next turn
    Then cards should move as follows
      Then Chas should discard everything from his hand
      And Chas should discard everything from play
      And Chas should draw 5 cards
      And I should move Copper, Silver, Gold from being set aside to my hand

  Scenario: Playing Research, trashing a 0-cost card
    Given pending

  Scenario: Playing Research, hand is empty
    Given pending

  Scenario: Playing Research, not enough cards in deck
    Given pending
