# Project (cost: 3) - At the start of your turn, +1 Card,
# then put a card from your hand onto your deck.
Feature: City Gate
  Background:
    Given I am in a 3 player game
    And my hand contains Copper, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains the City Gate project
    Then I should need to "Play an Action, or pass"

  Scenario: City Gate occurring
    And my deck contains Copper, Estate x2, Curse x2, Gold
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the City Gate project
    When I pass through to just before my next turn
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Choose a card to put on your deck"
    And I should be able to choose Copper, Estate x2, Curse x2, Gold in my hand
    And I should not be able to choose nothing in my hand
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should move Copper from my hand to my deck
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: City Gate occurring, nothing in deck
    And my deck contains nothing
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the City Gate project
    When I pass through to my next turn
    And I should need to "Choose a card to put on your deck"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should move Copper from my hand to my deck
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: City Gate occurring, nothing in deck or hand
    And my deck contains nothing
    And my hand contains nothing
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    Given I have the City Gate project
    When I pass through to my next turn
    Then I should need to "Play an Action, or pass"
