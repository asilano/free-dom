Feature:
  Background:
    Given I am in a 3 player game

  Scenario:
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose nothing in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      Then I should discard everything from my hand
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"
