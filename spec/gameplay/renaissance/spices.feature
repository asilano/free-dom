# Treasure (cost: 5) - $2
# +1 Buy
# When you gain this, +2 Coffers.
Feature: Spices
  Background:
    Given I am in a 3 player game
    And my hand contains Spices, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Spices
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"

  Scenario: Playing Spices
    When I choose Spices in my hand
    Then I should have 2 cash
    And I should have 2 buys
    And I should have 2 Coffers
    And I should need to "Play Treasures, or pass"
    And I should need to "Spend Coffers"
