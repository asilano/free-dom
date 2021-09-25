# Treasure (cost: 2) -+1 Coffers. +1 Buy. When you gain this, you may trash a Copper from your hand.
Feature: Ducat
  Background:
    Given I am in a 3 player game
    And my hand contains Ducat, Estate, Estate, Copper, Silver
    And the kingdom choice contains Ducat

  Scenario: Play Ducat, spend Coffer immediately
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 1 Coffers

  Scenario: Buy Ducat, trash Copper
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    And I should need to "Buy a card, or pass"
    When I choose Ducat in the supply
    Then cards should move as follows:
      Then I should gain Ducat
      And these card moves should happen
    And I should need to "Choose whether to trash a Copper"
    When I choose the option 'Trash'
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Buy Ducat, decline to trash Copper
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    And I should need to "Buy a card, or pass"
    When I choose Ducat in the supply
    Then cards should move as follows:
      Then I should gain Ducat
      And these card moves should happen
    And I should need to "Choose whether to trash a Copper"
    When I choose the option "Don't trash"
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Buy Ducat, not holding a Copper
    When my hand contains Ducat, Estate, Estate, Gold, Silver
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    And I should need to "Buy a card, or pass"
    When I choose Ducat in the supply
    Then cards should move as follows:
      Then I should gain Ducat
      And these card moves should happen
    And I should need to "Choose whether to trash a Copper"
    And I should not be able to choose the option "Trash"
    When I choose the option "Don't trash"
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Gain without Buy Ducat, trash Copper
    When my hand contains Workshop, Estate, Copper, Gold, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Workshop in my hand
    And I should need to 'Choose a card to gain'
    When I choose Ducat in the supply
    Then cards should move as follows:
      Then I should gain Ducat
      And these card moves should happen
    And I should need to "Choose whether to trash a Copper"
    When I choose the option 'Trash'
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"
