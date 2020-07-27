# Action (cost: 3) — +1 Card. +1 Action. The first time you play a Silver this turn, +1 Cash.
Feature: Merchant
  Background:
    Given I am in a 3 player game
    And my hand contains Merchant x2, Copper, Silver x2
    And my deck contains Silver x2

  Scenario: Playing one Merchant, then a Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have 3 cash

  Scenario: Merchant affects only the first Silver played
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have 3 cash
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have 5 cash

  Scenario: Merchant does not affect and is not affected by non-Silver treasures
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Copper in my hand
    Then I should have 1 cash
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have 4 cash

  Scenario: Multiple Merchants affect the first Silver played
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have 4 cash
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have 6 cash

  Scenario: Merchant should not affect next turn
    Then I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Play an Action, or pass'
    When I choose Merchant in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    And I choose nothing in my hand
    Then I should need to "Buy a card, or pass"
    And I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to 'Play an Action, or pass'
    When Belle chooses "Leave Action Phase" in her hand
    Then Belle should need to "Play Treasures, or pass"
    When Belle chooses nothing in her hand
    Then Belle should need to "Buy a card, or pass"
    When Belle chooses "Buy nothing" in the supply
    Then cards should move as follows:
      Then Belle should discard everything from her hand
      And Belle should discard everything from play
      And Belle should draw 5 cards
      And these card moves should happen
    And Chas should need to 'Play an Action, or pass'
    When Chas chooses "Leave Action Phase" in his hand
    Then Chas should need to "Play Treasures, or pass"
    When Chas chooses nothing in his hand
    Then Chas should need to "Buy a card, or pass"
    When Chas chooses "Buy nothing" in the supply
    Then cards should move as follows:
      Then Chas should discard everything from his hand
      And Chas should discard everything from play
      And Chas should draw 5 cards
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have 2 cash
