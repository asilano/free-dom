# Artifact (cost: 5) - +$3
# Choose one: Trash a Treasure from your hand;
#  or gain a Treasure from the trash to your hand;
#  or take the Key.
Feature: Treasurer
  Background:
    Given I am in a 3 player game
    And my hand contains Treasurer, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Treasurer
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Treasurer - choose to Trash
    When I choose Treasurer in my hand
    Then I should have $3
    And I should need to "Choose mode for Treasurer"
    When I choose the option "Trash a Treasure"
    Then I should need to "Choose a Treasure to trash"
    Then I should be able to choose Gold in my hand
    Then I should not be able to choose Market in my hand
    When I choose Gold in my hand
    Then cards should move as follows:
      Then I should trash Gold from my hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Treasurer - choose to gain from Trash
    Given the trash contains Silver, Scepter, Village
    When I choose Treasurer in my hand
    Then I should have $3
    And I should need to "Choose mode for Treasurer"
    When I choose the option "Gain a Treasure"
    Then I should need to "Choose a Treasure to gain from trash"
    And I should be able to choose Silver, Scepter in the trash
    And I should not be able to choose Village in the trash
    And I should not be able to choose nothing in the trash
    When I choose Scepter in the trash
    Then cards should move as follows:
      Then I should gain Scepter from trash to my discard
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Treasurer - choose to take the Key
    When I choose Treasurer in my hand
    Then I should have $3
    And I should need to "Choose mode for Treasurer"
    When I choose the option "Take the Key"
    Then I should have the Key
    And I should need to "Play Treasures, or pass"

  Scenario: Key acts at start of turn
    Given I have the Key
    When I pass through to my next turn
    Then I should have $1

  Scenario: Choose to Trash when can't
    Given my hand contains Treasurer, Market, Village, Curse
    When I choose Treasurer in my hand
    Then I should have $3
    And I should need to "Choose mode for Treasurer"
    When I choose the option "Trash a Treasure"
    Then I should need to "Choose a Treasure to trash"
    Then I should be able to choose nothing in my hand
    Then I should not be able to choose Market in my hand
    When I choose "Trash nothing" in my hand
    Then cards should not move
    And I should need to "Play Treasures, or pass"

  Scenario: Choose to gain from Trash when can't
    When I choose Treasurer in my hand
    Then I should have $3
    And I should need to "Choose mode for Treasurer"
    When I choose the option "Gain a Treasure"
    Then I should need to "Choose a Treasure to gain from trash"
    And I should be able to choose nothing in the trash
    When I choose "Gain nothing" in the trash
    Then cards should not move
    And I should need to "Play Treasures, or pass"