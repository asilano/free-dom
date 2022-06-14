# Type (cost: n) - Card text
Feature: Capitalism
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Bandit, Mine
    And the kingdom choice contains Market
    And the kingdom choice contains the Capitalism project
    Then I should need to "Play an Action, or pass"

  Scenario: Capitalism lets me play Actions as Treasures
    When I choose "Leave Action Phase" in my hand
    Given I have the Capitalism project
    Then I should need to "Play Treasures, or pass"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should move Market from my hand to in play
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 cash
    And I should need to "Play Treasures, or pass"

  Scenario: Capitalism lets me trash and gain Actions as Treasures (via Mine)
    Given I have the Capitalism project
    When I choose Mine in my hand
    Then I should need to 'Choose a Treasure to trash'
    When I choose Cargo Ship in my hand
    Then cards should move as follows:
      Then I should trash Cargo Ship from my hand
      And these card moves should happen
    And I should need to 'Choose a Treasure to gain to hand'
    And I should be able to choose the Copper, Silver, Gold, Market piles
    When I choose Market in the supply
    Then cards should move as follows:
      Then I should gain Market to my hand
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Capitalism affects other players' Actions (via Bandit)
    Given I have the Capitalism project
    When Belle's deck contains Market, Merchant
    And Chas's deck contains Flag Bearer, Priest
    Then I should need to "Play an Action, or pass"
    When I choose Bandit in my hand
    Then cards should move as follows:
      Then I should gain Gold
      And Belle should reveal 2 cards from her deck
      And Chas should reveal 2 cards from his deck
      And these card moves should happen
    And Market, Merchant should be revealed on Belle's deck
    And Belle should need to "Choose a treasure to trash"
    When Belle chooses Market in her revealed cards
    Then cards should move as follows:
      Then Belle should trash Market from her deck
      And Belle should discard Merchant from her deck
      And these card moves should happen
    And Flag Bearer, Priest should be revealed on Chas's deck
    And Chas should need to "Choose a treasure to trash"
    When Chas chooses Priest in his revealed cards
    Then cards should move as follows:
      And Chas should trash Priest from his deck
      And Chas should discard Flag Bearer from his deck
      And these card moves should happen
