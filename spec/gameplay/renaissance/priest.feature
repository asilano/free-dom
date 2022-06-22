# Action (cost: 4) - +$2. Trash a card from your hand. For the rest of this turn, when you trash a card, +$2.
Feature: Priest
  Background:
    Given I am in a 3 player game
    And my hand contains Priest, Chapel, Cargo Ship, Gold, Village
    And my deck contains Copper x5
    And the kingdom choice contains Priest
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Priest, nothing further
    When I choose Priest in my hand
    Then I should have $2
    And I should need to "Choose a card to trash"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should trash Village from my hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Priest, then trashing some cards
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose Priest in my hand
    Then I should have $2
    And I should need to "Choose a card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose Chapel in my hand
    Then I should need to "Trash up to 4 cards"
    When I choose Cargo Ship, Gold in my hand
    Then cards should move as follows:
      Then I should trash Cargo Ship, Gold from my hand
      And these card moves should happen
    And I should have $6
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Priest, then trashing owned not from hand
    Given my hand contains Village, Priest, Copper, Acting Troupe
    Then I should need to "Play an Action, or pass"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose Priest in my hand
    Then I should have $2
    And I should need to "Choose a card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose Acting Troupe in my hand
    Then cards should move as follows:
      Then I should trash Acting Troupe from in play
    And I should have $4
    And I should need to "Spend Villagers"

  # Requires Lurker
  Scenario: Playing Priest, then trashing not owned
    Given pending Lurker

  Scenario: Playing two Priests, then trashing
    Given my hand contains Village, Village, Priest, Priest, Copper, Acting Troupe
    Then I should need to "Play an Action, or pass"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose Priest in my hand
    Then I should have $2
    And I should need to "Choose a card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should have $2
    And I should need to "Play an Action, or pass"
    When I choose Priest in my hand
    Then I should have $4
    And I should need to "Choose a card to trash"
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper from my hand
      And these card moves should happen
    And I should have $6
    And I should need to "Play an Action, or pass"
    When I choose Acting Troupe in my hand
    Then cards should move as follows:
      Then I should trash Acting Troupe from in play
    And I should have $10

  Scenario: Repeat-playing a Priest, then trashing
    Given my hand contains Village, Priest, Throne Room, Estate x2, Chapel, Copper
    Then I should need to "Play an Action, or pass"
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    When I choose Throne Room in my hand
    Then I should need to "Choose an Action to play twice"
    When I choose Priest in my hand
    Then cards should move as follows:
      Then I should move Priest from my hand to in play
      And these card moves should happen
    And I should need to "Choose a card to trash"
    When I choose Estate in my hand
    Then cards should move as follows:
      Then I should trash Estate from my hand
      And these card moves should happen
    And I should need to "Choose a card to trash"
    When I choose Estate in my hand
    Then cards should move as follows:
      Then I should trash Estate from my hand
      And these card moves should happen
    And I should have $6
    And I should need to "Play an Action, or pass"
    When I choose Chapel in my hand
    Then I should need to "Trash up to 4 cards"
    When I choose Copper, Copper in my hand
    Then cards should move as follows:
      Then I should trash Copper x2 from my hand
      And these card moves should happen
    And I should have $14
    And I should need to "Play Treasures, or pass"

  # Requires Sewers
  Scenario: Trashing as trigger during Priest doesn't grant cash.
    Given pending Sewers

  # Requires Loan or Counterfeit
  Scenario: Trashing during Treasure phase
    Given pending Loan or Counterfeit
