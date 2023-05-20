# Action (cost: 4) - Do this twice: Trash a card from your hand, then gain a card costing exactly $1 more than it.
Feature: Remake
  Background:
    Given I am in a 3 player game
    And my hand contains Remake, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Remake, Moneylender
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Remake, upgrade two cards
    When I choose Remake in my hand
    Then I should need to "Choose 1st card to trash"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should trash Market from my hand
      And these card moves should happen
    And I should need to "Choose a card to gain"
    And I should be able to choose the Gold pile
    And I should not be able to choose the Silver, Remake, Province piles
    And I should not be able to choose nothing in the supply
    When I choose Gold in the supply
    Then cards should move as follows:
      Then I should gain Gold
      And these card moves should happen
    Then I should need to "Choose 2nd card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should need to "Choose a card to gain"
    And I should be able to choose the Remake, Moneylender piles
    And I should not be able to choose the Silver, Gold, Province piles
    And I should not be able to choose nothing in the supply
    When I choose Moneylender in the supply
    Then cards should move as follows:
      Then I should gain Moneylender
      And these card moves should happen

  Scenario: Playing Remodel, declining to trash second time (nothing in hand)
    Given my hand contains Remake, Village
    Then I should need to "Play an Action, or pass"
    When I choose Remake in my hand
    Then I should need to "Choose 1st card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should need to "Choose a card to gain"
    And I should be able to choose the Remake, Moneylender piles
    And I should not be able to choose the Curse, Village, Gold piles
    And I should not be able to choose nothing in the supply
    When I choose Moneylender in the supply
    Then cards should move as follows:
      Then I should gain Moneylender
      And these card moves should happen
    Then I should need to "Choose 2nd card to trash"
    When I choose "Trash nothing" in my hand
    Then cards should not move
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Remodel, declining to trash both times (nothing in hand)
    Given my hand contains Remake
    Then I should need to "Play an Action, or pass"
    When I choose Remake in my hand
    Then I should need to "Choose 1st card to trash"
    When I choose "Trash nothing" in my hand
    Then cards should not move
    Then I should need to "Choose 2nd card to trash"
    When I choose "Trash nothing" in my hand
    Then cards should not move
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Remake, can't upgrade (no such card)
    Given my hand contains Remake, Copper
    Then I should need to "Play an Action, or pass"
    When I choose Remake in my hand
    Then I should need to "Choose 1st card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Choose a card to gain"
    And I should not be able to choose the Gold, Silver, Remake, Province piles
    And I should be able to choose nothing in the supply
    When I choose "Gain nothing" in the supply
    Then cards should not move
    And I should need to "Choose 2nd card to trash"

  Scenario: Playing Remake, can't upgrade (pile is empty)
    Given the Gold pile is empty
    And the Artisan pile is empty
    Then I should need to "Play an Action, or pass"
    When I choose Remake in my hand
    Then I should need to "Choose 1st card to trash"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should trash Market from my hand
      And these card moves should happen
    And I should need to "Choose a card to gain"
    And I should not be able to choose the Gold, Silver, Remake, Province piles
    And I should be able to choose nothing in the supply
    When I choose "Gain nothing" in the supply
    Then cards should not move
    And I should need to "Choose 2nd card to trash"
