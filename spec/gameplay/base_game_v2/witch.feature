# Action/Attack (cost: 5) - +2 Cards
# Each other player gains a Curse.
Feature: Witch
  Background:
    Given I am in a 3 player game
    And my hand contains Witch, Estate, Copper, Silver, Gold
    When my deck contains Throne Room, Gold, Cellar, Copper

  Scenario: Playing Witch draws cards and gives Curses
    Then I should need to 'Play an Action, or pass'
    When I choose Witch in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And Belle should gain Curse
      And Chas should gain Curse
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Witch can't give Curse when none are left
    And the Curse pile is empty
    Then I should need to 'Play an Action, or pass'
    When I choose Witch in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Witch gives Curse as far as possible
    And the Curse pile contains Curse
    Then I should need to 'Play an Action, or pass'
    When I choose Witch in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And Belle should gain Curse
      And these card moves should happen
    And I should need to "Play Treasures, or pass"
