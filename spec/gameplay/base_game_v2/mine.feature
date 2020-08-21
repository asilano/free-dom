# Action (cost: 5) - You may trash a Treasure from your hand. Gain a Treasure to your hand costing up to 3 more than it.
Feature: Mine
  Background:
    Given I am in a 3 player game
    And my hand contains Mine, Copper, Silver, Gold, Village

  Scenario: Playing Mine, upgrade Copper to Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Mine in my hand
    Then I should need to 'Choose a Treasure to trash'
    And I should be able to choose Copper, Silver, Gold in my hand
    And I should not be able to choose Village in my hand
    And I should be able to choose nothing in my hand
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to 'Choose a Treasure to gain to hand'
    And I should be able to choose the Copper, Silver piles
    And I should not be able to choose the Gold, Duchy piles
    And I should not be able to choose nothing in the supply
    When I choose Silver in the supply
    Then cards should move as follows:
      Then I should gain Silver to my hand
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Mine, trashing Silver allows taking Copper to Gold
    Then I should need to 'Play an Action, or pass'
    When I choose Mine in my hand
    Then I should need to 'Choose a Treasure to trash'
    When I choose Silver in my hand
    Then cards should move as follows:
      Then I should trash Silver from my hand
      And these card moves should happen
    And I should need to 'Choose a Treasure to gain to hand'
    And I should be able to choose the Copper, Silver, Gold piles
    And I should not be able to choose the Duchy piles

  Scenario: Playing Mine, declining to trash
    Then I should need to 'Play an Action, or pass'
    When I choose Mine in my hand
    Then I should need to 'Choose a Treasure to trash'
    When I choose 'Trash nothing' in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Mine, declining to trash (no treasures in hand)
    When my hand contains Mine, Estate, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Mine in my hand
    Then I should need to 'Choose a Treasure to trash'
    When I choose 'Trash nothing' in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Mine, declining to take replacement (none available)
    When the Copper pile is empty
    And the Silver pile is empty
    Then I should need to 'Play an Action, or pass'
    When I choose Mine in my hand
    Then I should need to 'Choose a Treasure to trash'
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to 'Choose a Treasure to gain to hand'
    And I should be able to choose nothing in the supply
    When I choose 'Gain nothing' in the supply
    Then cards should not move
    And I should need to 'Play Treasures, or pass'
