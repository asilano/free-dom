# Project (cost: 3) - When you shuffle, you may pick one of the cards to go on top.
Feature: Star Chart
  Background:
    Given I am in a 3 player game
    And the kingdom choice contains the Star Chart project

  Scenario: Shuffle from draw
    Given I have the Star Chart project
    And my deck contains Estate
    And my discard contains Silver, Gold, Curse x3
    And my hand contains Smithy
    Then I should need to "Play an Action, or pass"
    When I choose Smithy in my hand
    Then I should need to "Choose a card to put on top of shuffle"
    When I choose Gold in my discard
    Then cards should move as follows:
      # Note - cards don't _actually_ move like this
      Then I should draw 1 card
      And I should move Gold, Curse x3, Silver from my discard to my deck
      And I should draw 2 cards
      And these card moves should happen

  Scenario: Shuffle from end-of-turn draw
    Given I have the Star Chart project
    And my deck contains Estate
    And my hand contains Village
    And my discard contains Silver, Gold, Curse x3
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And these card moves should happen
    Then I should need to "Choose a card to put on top of shuffle"
    When I choose Village in my discard
    Then cards should move as follows:
      # Note - cards don't _actually_ move like this
      Then I should draw 1 card
      And I should move Village, Curse x3, Gold, Silver from my discard to my deck
      And I should draw 4 cards
      And these card moves should happen

  Scenario: Shuffle from peek/reveal
    Given I have the Star Chart project
    And my deck contains Estate
    And my discard contains Silver, Gold, Curse x3
    And my hand contains Sentry
    Then I should need to "Play an Action, or pass"
    When I choose Sentry in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    Then I should need to "Choose a card to put on top of shuffle"
    When I choose Silver in my discard
    Then cards should move as follows:
      And I should move Silver, Curse x3, Gold from my discard to my deck
      And these card moves should happen
    And I should need to 'Trash and/or discard cards on your deck'
