# Action (cost: 4) - Gain a card costing up to 4, then cards cost 1 less this turn (but not less than 0).
Feature: Inventor
  Background:
    Given I am in a 3 player game
    And my hand contains Inventor, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Inventor, Workshop, Bureaucrat, Market
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Inventor, gain Workshop, costs reduced
    When I choose Inventor in my hand
    Then I should need to "Choose a card to gain"
    And I should be able to choose the Copper, Workshop, Bureaucrat piles
    And I should not be able to choose the Market, Gold, Province piles
    When I choose Bureaucrat in the supply
    Then cards should move as follows:
      Then I should gain Bureaucrat
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
    Then the Copper pile should cost 0
    And the Inventor pile should cost 3
    And the Gold pile should cost 5

  Scenario: Playing two Inventors, costs reduced twice
    Given my hand contains Inventor x2, Market, Cargo Ship, Gold, Village
    Then I should need to "Play an Action, or pass"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    Then I should need to "Play an Action, or pass"
    When I choose Inventor in my hand
    Then I should need to "Choose a card to gain"
    When I choose Bureaucrat in the supply
    Then cards should move as follows:
      Then I should gain Bureaucrat
      And these card moves should happen
    Then I should need to "Play an Action, or pass"
    When I choose Inventor in my hand
    Then I should need to "Choose a card to gain"
    And I should be able to choose the Copper, Workshop, Bureaucrat, Market piles
    And I should not be able to choose the Gold, Province piles
    When I choose Market in the supply
    Then cards should move as follows:
      Then I should gain Market
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
    Then the Copper pile should cost 0
    And the Inventor pile should cost 2
    And the Gold pile should cost 4

  Scenario: Cost reductions only last one turn
    When I choose Inventor in my hand
    Then I should need to "Choose a card to gain"
    And I should be able to choose the Copper, Workshop, Bureaucrat piles
    And I should not be able to choose the Market, Gold, Province piles
    When I choose Bureaucrat in the supply
    Then cards should move as follows:
      Then I should gain Bureaucrat
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
    When I pass through to Belle's next turn
    Then the Inventor pile should cost 4
    And the Province pile should cost 8
