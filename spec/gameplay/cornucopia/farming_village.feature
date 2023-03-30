# Action (cost: 4) - +2 Actions
# Reveal cards from your deck until you reveal a Treasure or Action card.
# Put that card into your hand and discard the rest.
Feature: Farming Village
  Background:
    Given I am in a 3 player game
    And my hand contains Farming Village, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Farming Village, Patron
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Farming Village, hit Copper immediately
    Given my deck contains Copper, Market, Estate, Silver
    When I choose Farming Village in my hand
    Then cards should move as follows:
      Then I should move Copper from my deck to my hand
      And these card moves should happen
    And I should have 2 actions

  Scenario: Playing Farming Village, hit Scepter
    Given my deck contains Estate, Curse, Scepter, Market, Estate, Silver
    When I choose Farming Village in my hand
    Then cards should move as follows:
      Then I should discard Estate, Curse from my deck
      Then I should move Scepter from my deck to my hand
      And these card moves should happen
    And I should have 2 actions

  Scenario: Playing Farming Village, hit Market as last card in the deck
    Given my deck contains Estate, Curse, Province, Market
    When I choose Farming Village in my hand
    Then cards should move as follows:
      Then I should discard Estate, Curse, Province from my deck
      Then I should move Market from my deck to my hand
      And these card moves should happen
    And I should have 2 actions

  Scenario: Playing Farming Village, hit a dual Action-Victory
    Given pending "dual-type Action-Victory"

  Scenario: Playing Farming Village, hit a different dual type card
    Given pending "dual-type card"

  Scenario: Playing Farming Village, no targets until after shuffle
    Given my deck contains Estate, Curse
      And my discard contains Estate, Market, Province
    When I choose Farming Village in my hand
    Then cards should move as follows:
      Then I should shuffle my discards
      And I should discard Estate, Curse, Estate from my deck
      And I should move Market from my deck to my hand
      And these card moves should happen
    And I should have 2 actions

  Scenario: Playing Farming Village, no targets
    Given my deck contains Estate, Curse
      And my discard contains Estate, Duchy, Province
    When I choose Farming Village in my hand
    Then cards should move as follows:
      Then I should shuffle my discards
      And I should discard Estate, Curse, Duchy, Estate, Province from my deck
      And these card moves should happen
    And I should have 2 actions

  Scenario: Playing Farming Village, deck contains an on-reveal trigger as first target
    Given my deck contains Estate, Curse, Patron, Market, Estate, Silver
    When I choose Farming Village in my hand
    Then cards should move as follows:
      Then I should discard Estate, Curse from my deck
      Then I should move Patron from my deck to my hand
      And these card moves should happen
    And I should have 2 actions
    And I should have 1 Coffers
