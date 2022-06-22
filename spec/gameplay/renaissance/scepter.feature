# Treasure (cost: 5) - When you play this, choose one: +$2;
# or replay an Action card you played this turn that's still in play.
Feature: Scepter
  Background:
    Given I am in a 3 player game
    And my hand contains Scepter, Market, Research, Gold, Village x2
    And the kingdom choice contains Scepter
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Scepter, choose cash
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Scepter in my hand
    Then I should need to "Choose mode for Scepter"
    When I choose the option "Gain cash"
    Then I should have $2
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Scepter, choose to replay, replay a choice of cards
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    Then I should need to "Play an Action, or pass"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    And I should have $1
    And I should have 2 buys
    When I choose Scepter in my hand
    Then I should need to "Choose mode for Scepter"
    When I choose the option "Replay Action"
    Then I should need to "Choose an Action to replay"
    When I choose Market in play
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have $2
    And I should have 3 buys
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Scepter, choose to replay, one choice
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Scepter in my hand
    Then I should need to "Choose mode for Scepter"
    When I choose the option "Replay Action"
    Then I should need to "Choose an Action to replay"
    When I choose Village in play
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Scepter, choose to replay, nothing played this turn
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Scepter in my hand
    Then I should need to "Choose mode for Scepter"
    When I choose the option "Replay Action"
    Then I should need to "Choose an Action to replay"
    When I choose "Choose nothing" in play
    Then cards should not move
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Scepter, choose to replay, choose a duration, Scepter tracks
    Given my deck contains Copper, Silver, Gold, Estate x5
    When I choose Research in my hand
    Then I should need to "Choose a card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And I should set aside Copper, Silver, Gold from my deck on my Research in play
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Scepter in my hand
    Then I should need to "Choose mode for Scepter"
    When I choose the option "Replay Action"
    Then I should need to "Choose an Action to replay"
    When I choose Research in play
    Then I should need to "Choose a card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And I should set aside Estate x3 from my deck on my Research in play
      And these card moves should happen
    And I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard Market, Gold from my hand
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Playing Scepter, choose to replay, can't choose last turn's duration
    Given my deck contains Copper, Silver, Gold, Estate x5
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
      And I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"
    When Belle passes through to just before my next turn
      Then I should move Copper, Silver, Gold from being set aside to my hand
      And these card moves should happen
    Given my hand contains Scepter, Village
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Scepter in my hand
    Then I should need to "Choose mode for Scepter"
    When I choose the option "Replay Action"
    Then I should need to "Choose an Action to replay"
    And I should not be able to choose Research in play

  Scenario: Playing Scepter, choose to replay, can't choose a card that was played then left
    Given pending, needs gain from trash, see Discord
