Feature: Throne Room-Prince
  Throne Rooming a Prince doesn't work so well: you can only set aside one card
  Princing a Throne Room fails if the TR is then used on a duration.

  Background:
    Given I am a player in a standard game

  Scenario: Throne Room
    Given my hand contains Prince, Throne Room, Village, Great Hall
      And it is my Play Action phase
    When I play Throne Room
    And I choose Prince in my hand
    And the game checks actions
      Then I should have played Prince
      And I should need to Choose a card to set aside with Prince
    When I choose Village in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Village from my hand
        And I should have removed Prince from play
    When the game checks actions
      Then it should be my Buy phase

  Scenario: King's Court
    Given my hand contains Prince, King's Court, Village, Great Hall
      And it is my Play Action phase
    When I play King's Court
    And I choose Prince in my hand
    And the game checks actions
      Then I should have played Prince
      And I should need to Choose a card to set aside with Prince
    When I choose Village in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Village from my hand
        And I should have removed Prince from play
    When the game checks actions
      Then it should be my Buy phase

  Scenario: Prince-Throning a Duration
    Given my hand contains Prince, Throne Room, Estate x3
      And my deck contains Caravan, Estate x4, Duchy x2, Estate x5, Duchy x2
      And it is my Play Action phase
    When I play Prince
    And I choose Throne Room in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Throne Room from my hand
        And I should have removed Prince from play
    And the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have placed Throne Room in enduring
        And I should have played Caravan
        And I should have drawn 2 cards
      And it should be my Play Action phase
      And I should have 3 actions available
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Throne Room, Caravan from enduring to play
        And I should have drawn 2 cards
      And it should be my Play Action phase
      And I should have 1 action available
    When my next turn starts
      Then it should be my Play Action phase
      And I should have 1 action available

