# Action/Attack (cost: 5) - +3 Cards
# Each other player gains a Curse and may trash a Curse from their hand.
Feature: Old Witch
  Background:
    Given I am in a 3 player game
    And my hand contains Old Witch, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Old Witch
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Old Witch gives and allows trashing of Curses
    Given Belle's hand contains Copper, Silver, Village, Curse x2
    And Chas's hand contains Curse
    When I choose Old Witch in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And Belle should gain Curse
      And Chas should gain Curse
      And these card moves should happen
    And Belle should need to "Choose whether to trash a Curse"
    And Chas should need to "Choose whether to trash a Curse"
    And I should not need to act
    When Chas chooses the option "Trash"
    Then cards should move as follows:
      Then Chas should trash Curse from his hand
      And these card moves should happen
    And Belle should need to "Choose whether to trash a Curse"
    When Belle chooses the option "Don't trash"
    Then cards should not move
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Old Witch can't give Curse when none are left
    And the Curse pile is empty
    When I choose Old Witch in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Old Witch gives Curse as far as possible
    And the Curse pile contains Curse
    When I choose Old Witch in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And Belle should gain Curse
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Old Witch allows trashing of Curses even if can't give them
    Given Chas's hand contains Curse
    And the Curse pile is empty
    When I choose Old Witch in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
        And Chas should need to "Choose whether to trash a Curse"
    And I should not need to act
    When Chas chooses the option "Trash"
    Then cards should move as follows:
      Then Chas should trash Curse from his hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"
