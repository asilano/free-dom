# Action (cost: 5) - Gain a card to your hand costing up to $4. If it's a Treasure, +1 Villager.
Feature: Sculptor
  Background:
    Given I am in a 3 player game
    And my hand contains Sculptor, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Village, Bureaucrat
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Sculptor normally, gain non-treasure
    Then I should need to 'Play an Action, or pass'
    When I choose Sculptor in my hand
    Then I should need to 'Choose a card to gain'
    And I should be able to choose the Copper, Village, Bureaucrat piles
    And I should not be able to choose the Market, Gold, Province piles
    When I choose Bureaucrat in the supply
    Then cards should move as follows:
      Then I should gain Bureaucrat to my hand
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Sculptor normally, gain treasure
    Then I should need to 'Play an Action, or pass'
    When I choose Sculptor in my hand
    Then I should need to 'Choose a card to gain'
    And I should be able to choose the Silver, Village, Bureaucrat piles
    And I should not be able to choose the Market, Gold, Province piles
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver to my hand
      And these card moves should happen
    And I should need to 'Leave the Action phase'
    And I should have 1 Villager
