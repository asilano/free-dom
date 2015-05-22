Feature: Prince-Island
  A Princed Island will only trigger once, because it's no longer set aside at turn end.

  Background:
    Given I am a player in a standard game

  Scenario: Princed Island only triggers once
    Given my hand contains Prince, Island, Copper x3
      And my deck contains Duchy, Estate x10
      And it is my Play Action phase
    When I play Prince
    And I choose Island in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Island from my hand
        And I should have removed Prince from play
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then I should have placed Island in play
      And I should need to Set a card aside with Island
    When I choose Duchy in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Island from play
        And I should have removed Duchy from my hand
      And it should be my Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then it should be my Play Action phase
