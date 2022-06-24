# Project (cost: 7) - During your turns, cards cost $1 less.
Feature: Canal
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Village, Remodel, Copper
    And the kingdom choice contains Inventor, Workshop, Bureaucrat, Market
    And the kingdom choice contains the Canal project

  Scenario: Canal reduces pile costs (but not below 0)
    Given I have the Canal project
    Then I should need to "Play an Action, or pass"
    Then the Estate pile should cost 1
    And the Market pile should cost 4
    And the Gold pile should cost 5
    And the Copper pile should cost 0

  Scenario: Canal reduces all costs (so upgrade type cards work as normal)
    Given I have the Canal project
    Then I should need to "Play an Action, or pass"
    When I choose Remodel in my hand
    Then I should need to "Choose a card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should need to "Choose a card to gain"
    And I should be able to choose the Copper, Silver, Bureaucrat, Duchy, Market piles
    And I should not be able to choose the Gold, Province piles

  Scenario: Canal reduces all costs and stops at 0
    Given I have the Canal project
    Then I should need to "Play an Action, or pass"
    When I choose Remodel in my hand
    Then I should need to "Choose a card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Choose a card to gain"
    And I should be able to choose the Copper, Silver piles
