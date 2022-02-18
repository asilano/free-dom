# Action (cost: 5) - +2 Cards
# Trash a card from your hand. +1 Villager per $1 it costs.
Feature: Recruiter
  Background:
    Given I am in a 3 player game
    And my hand contains Recruiter, Market, Cargo Ship, Copper, Village
    And the kingdom choice contains Recruiter
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Recruiter
    When I choose Recruiter in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should need to 'Choose a card to trash'
    And I should be able to choose Copper, Village, Market, Cargo Ship in my hand
    And I should not be able to choose nothing in my hand
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should have 3 Villagers
    And I should need to "Leave the Action phase"

  Scenario: Playing Recruiter, trashing a 0-cost
    When I choose Recruiter in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should need to 'Choose a card to trash'
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should have 0 Villagers
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Recruiter, can't draw, hand not empty
    Given my deck contains nothing
    When I choose Recruiter in my hand
    Then cards should not move
    And I should need to 'Choose a card to trash'
    And I should be able to choose Copper, Village, Market, Cargo Ship in my hand
    And I should not be able to choose nothing in my hand
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should have 3 Villagers
    And I should need to "Leave the Action phase"

  Scenario: Playing Recruiter, can't draw, hand empty
    Given my deck contains nothing
    And my hand contains Recruiter
    When I choose Recruiter in my hand
    Then cards should not move
    And I should need to 'Choose a card to trash'
    And I should be able to choose nothing in my hand
    When I choose 'Trash nothing' in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'