# Action (cost: 4) - +2 Cards
# +1 Buy
# When you gain or trash this, +1 Coffers and +1 Villager.
Feature: Silk Merchant
  Background:
    Given I am in a 3 player game
    And my hand contains Silk Merchant, Remodel, Cargo Ship, Gold, Village
    And the kingdom choice contains Silk Merchant
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Silk Merchant
    When I choose Silk Merchant in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should have 2 buys
    And I should need to "Play Treasures, or pass"

  Scenario: Gaining Silk Merchant
    When I choose Remodel in my hand
    Then I should need to 'Choose a card to trash'
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should need to 'Choose a card to gain'
    When I choose Silk Merchant in the supply
    Then cards should move as follows:
      Then I should gain Silk Merchant
      And these card moves should happen
    And I should need to 'Spend Villagers'
    And I should have 1 Coffers
    And I should have 1 Villagers

  Scenario: Trashing Silk Merchant
    When I choose Remodel in my hand
    Then I should need to 'Choose a card to trash'
    When I choose Silk Merchant in my hand
    Then cards should move as follows:
      Then I should trash Silk Merchant from my hand
      And these card moves should happen
    And I should need to 'Choose a card to gain'
    And I should have 1 Coffers
    And I should have 1 Villagers
