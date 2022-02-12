# Action-Duration (cost: 4) - +1 Action
# Trash a card from your hand. Per 1 Cash it costs, set aside a card from your deck face down (on this). At the start of your next turn, put those cards into your hand.
Feature: Research
  Background:
    Given I am in a 3 player game
    And my hand contains Research, Copper, Cargo Ship, Gold, Village
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
    And Copper, Silver, Gold on my Research should be visible to me
    And Copper, Silver, Gold on my Research should not be visible to Belle
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      And I should discard Copper, Cargo Ship, Gold from my hand
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"
    When Belle passes through to just before my next turn
      Then I should move Copper, Silver, Gold from being set aside to my hand
      And these card moves should happen
    When I pass through to Belle's next turn
    Then Belle should need to "Play an Action, or pass"

  Scenario: Playing Research, trashing a 0-cost card
    When I choose Research in my hand
    Then I should have 1 action
    And I should need to "Choose a card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      And I should discard Village, Cargo Ship, Gold from my hand
      And I should discard Research from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Playing Research, hand is empty
    Given my hand contains Research
    Then I should need to "Play an Action, or pass"
    When I choose Research in my hand
    Then I should have 1 action
    And I should need to "Choose a card to trash"
    When I choose "Trash nothing" in my hand
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      And I should discard Research from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Playing Research, not enough cards in deck
    Given my deck contains Copper
    When I choose Research in my hand
    Then I should have 1 action
    And I should need to "Choose a card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And I should set aside Copper from my deck on my Research in play
      And these card moves should happen
    And Copper on my Research should be visible to me
    And Copper on my Research should not be visible to Belle
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      And I should discard Copper, Cargo Ship, Gold from my hand
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"
    When Belle passes through to just before my next turn
      Then I should move Copper from being set aside to my hand
      And these card moves should happen
    When I pass through to Belle's next turn
    Then Belle should need to "Play an Action, or pass"
