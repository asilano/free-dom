# Project (cost: 3) - When you trash a card other than with this, you may trash a card from your hand.
Feature: Sewers
  Background:
    Given I am in a 3 player game
    And the kingdom choice contains the Sewers project
    And I have the Sewers project

  Scenario: Trashing due to Priest (spare trash, no cash gain)
    Given my hand contains Priest, Market, Cargo Ship, Gold, Village
    Then I should need to "Play an Action, or pass"
    When I choose Priest in my hand
    Then I should have 2 cash
    And I should need to "Choose a card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should need to "Choose an additional card to trash"
    And I should be able to choose Market, Cargo Ship, Gold in my hand
    And I should be able to choose nothing in my hand
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should trash Market from my hand
      And these card moves should happen
    And I should have 2 cash
    And I should need to "Play Treasures, or pass"

  Scenario: Trashing due to Chapel (multiple extra trashes), decline one
    Given my hand contains Chapel, Estate x3, Copper x3
    Then I should need to "Play an Action, or pass"
    When I choose Chapel in my hand
    Then I should need to 'Trash up to 4 cards'
    When I choose Estate x3 in my hand
    Then cards should move as follows:
      Then I should trash Estate x3 from my hand
      And these card moves should happen
    And I should need to "Choose an additional card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Choose an additional card to trash"
    When I choose "Trash nothing" in my hand
    Then cards should not move
    And I should need to "Choose an additional card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Trashing due to another player's Old Witch
    Given my deck contains Curse, Estate x4
    And Belle's hand contains Old Witch
    Then I should need to "Play an Action, or pass"
    When I pass through to Belle's next turn
    Then Belle should need to "Play an Action, or pass"
    When Belle chooses Old Witch in her hand
    Then cards should move as follows:
      Then Belle should draw 3 cards
      And I should gain Curse
      And Chas should gain Curse
      And these card moves should happen
    And I should need to "Choose whether to trash a Curse"
    When I chooses the option "Trash"
    Then cards should move as follows:
      Then I should trash Curse from my hand
      And these card moves should happen
    And I should need to "Choose an additional card to trash"

  Scenario: Self-Trashing an Acting Troupe
    Given my hand contains Acting Troupe, Market, Cargo Ship, Gold, Village
    Then I should need to "Play an Action, or pass"
    When I choose Acting Troupe in my hand
    Then I should have 4 Villagers
    And cards should move as follows:
      Then I should trash Acting Troupe from in play
      And these card moves should happen
    And I should need to "Choose an additional card to trash"

  Scenario: Trashing from supply with Lurker
    Given pending
