# Action (cost: 3) - Gain a card costing up to 4.
Feature: Artisan
  Background:
    Given I am in a 3 player game
    And the kingdom choice contains Market, Bureaucrat, Workshop
    And my hand contains Workshop, Estate, Copper, Silver

  Scenario: Play Workshop normally
    Then I should need to 'Play an Action, or pass'
    When I choose Workshop in my hand
    And I should need to 'Choose a card to gain'
    And I should be able to choose the Copper, Workshop, Bureaucrat piles
    And I should not be able to choose the Market, Gold, Province piles
    When I choose Bureaucrat in the supply
    Then cards should move as follows:
      Then I should gain Bureaucrat
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
