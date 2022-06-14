# Action (cost: 4) - +2 Cash
# When you gain or trash this, take the Flag.
# Flag - When drawing your hand, +1 Card.
Feature: Flag Bearer
  Background:
    Given I am in a 3 player game
    And my hand contains Flag Bearer, Market, Chapel, Gold
    And my deck contains Estate x10
    And the kingdom choice contains Flag Bearer
    And the kingdom choice contains the Capitalism project
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Flag Bearer
    When I choose Flag Bearer in my hand
    Then I should have 2 cash
    And I should need to "Play Treasures, or pass"

  Scenario: Take Flag on gain
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    And I should need to "Buy a card, or pass"
    When I choose Flag Bearer in the supply
    Then cards should move as follows:
      Then I should gain Flag Bearer
      And these card moves should happen
    And I should have the Flag

  Scenario: Take Flag on trash
    When I choose Chapel in my hand
    Then I should need to "Trash up to 4 cards"
    When I choose Flag Bearer, Market in my hand
    Then cards should move as follows:
      Then I should trash Flag Bearer, Market from my hand
      And these card moves should happen
    And I should have the Flag

  Scenario: Taking Flag takes it from previous owner
    Given Belle has the Flag
    When I choose Chapel in my hand
    Then I should need to "Trash up to 4 cards"
    When I choose Flag Bearer, Market in my hand
    Then cards should move as follows:
      Then I should trash Flag Bearer, Market from my hand
      And these card moves should happen
    And I should have the Flag
    And Belle should not have the Flag

  Scenario: Draw one more when have the Flag
    Given I have the Flag
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should discard everything from play
      And I should draw 6 cards
      And these card moves should happen
