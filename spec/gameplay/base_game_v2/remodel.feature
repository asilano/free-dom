# Action (cost: 4) - Trash a card from your hand. Gain a card costing up to 2 more than it.
Feature: Remodel
  Background:
    Given I am in a 3 player game
    And my hand contains Remodel, Copper, Village, Gold, Militia
    And the kingdom choice contains Cellar, Village, Remodel, Festival, Artisan

  Scenario: Playing Remodel, upgrade Copper to Estate
    Then I should need to 'Play an Action, or pass'
    When I choose Remodel in my hand
    Then cards should not move
    And I should need to 'Choose a card to trash'
    And I should be able to choose Copper, Village, Gold, Militia in my hand
    And I should not be able to choose nothing in my hand
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to 'Choose a card to gain'
    And I should be able to choose the Curse, Copper, Estate, Cellar piles
    And I should not be able to choose the Village, Gold, Duchy piles
    And I should not be able to choose nothing in the supply
    When I choose Estate in the supply
    Then cards should move as follows:
      Then I should gain Estate
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Remodel, trashing Village allows taking anything up to 5
    Then I should need to 'Play an Action, or pass'
    When I choose Remodel in my hand
    Then cards should not move
    And I should need to 'Choose a card to trash'
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should need to 'Choose a card to gain'
    And I should be able to choose the Copper, Cellar, Silver, Remodel, Duchy, Festival piles
    And I should not be able to choose the Gold, Province piles

  Scenario: Playing Remodel, declining to trash (nothing in hand)
    When my hand contains Remodel
    Then I should need to 'Play an Action, or pass'
    When I choose Remodel in my hand
    Then I should need to 'Choose a card to trash'
    When I choose 'Trash nothing' in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'
