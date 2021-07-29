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
    And I should have 2 buys
    And I should have 0 cash
    And I should need to "Play Treasures, or pass"
    When I spend 1 Coffers
    Then I should have 1 cash
    And I should have 0 Coffers

  Scenario: Play two Ducats, spend both immediately
    When my hand contains Ducat x2, Estate, Estate, Copper
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 1 Coffers
    And I should have 2 buys
    And I should have 0 cash
    And I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 2 Coffers
    And I should have 3 buys
    And I should have 0 cash
    When I spend 2 Coffers
    Then I should have 2 cash
    And I should have 0 Coffers
    When I choose 'Stop playing treasures' in my hand
    And I should need to "Buy a card, or pass"
    And I should be able to choose the Copper, Estate piles
    And I should not be able to choose the Silver, Gold, Duchy, Province piles

  Scenario: Play Ducat, save Coffer, spend it next turn
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 1 Coffers
    And I should have 2 buys
    And I should have 0 cash
    And I should need to "Play Treasures, or pass"
    And I choose 'Stop playing treasures' in my hand
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
    When Belle chooses 'Stop playing treasures' in her hand
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
    When Chas chooses 'Stop playing treasures' in his hand
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
    And I should have 1 Coffers
    And I should have 0 cash
    When I spend 1 Coffers
    Then I should have 1 cash
    And I should have 0 Coffers

  Scenario: Play two Ducats, spend one Coffer
    When my hand contains Ducat x2, Estate, Estate, Copper
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 1 Coffers
    And I should have 2 buys
    And I should have 0 cash
    And I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 2 Coffers
    And I should have 3 buys
    And I should have 0 cash
    When I spend 1 Coffers
    Then I should have 1 cash
    And I should have 1 Coffers

  Scenario: Play Ducat, spend Coffer, play more treasure
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 1 Coffers
    And I should have 2 buys
    And I should have 0 cash
    And I should need to "Play Treasures, or pass"
    When I spend 1 Coffers
    Then I should have 1 cash
    And I should have 0 Coffers
    And I should need to "Play Treasures, or pass"
    When I choose Silver in my hand
    Then I should have 3 cash
    And I should have 0 Coffers

  Scenario: Play two Ducats, spend one Coffer twice
    When my hand contains Ducat x2, Estate, Estate, Copper
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 1 Coffers
    And I should have 2 buys
    And I should have 0 cash
    And I should need to "Play Treasures, or pass"
    When I choose Ducat in my hand
    Then I should have 2 Coffers
    And I should have 3 buys
    And I should have 0 cash
    When I spend 1 Coffers
    Then I should have 1 cash
    And I should have 1 Coffers
    And I should need to "Play Treasures, or pass"
    When I spend 1 Coffers
    Then I should have 2 cash
    And I should have 0 Coffers

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
