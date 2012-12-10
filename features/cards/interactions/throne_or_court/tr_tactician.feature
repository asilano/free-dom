Feature: Throne Room + Tactician
  A Throne Roomed or King's Courted Tactician should give you exactly one set of bonuses next turn.
  
  Background:
    Given I am a player in a standard game with Throne Room, Tactician
  
  Scenario:
    Given my hand contains Throne Room, Tactician, Estate x3
      And it is my Play Action phase
    When I play Throne Room
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have played Tactician
        And I should have moved Throne Room from play to enduring
        And I should have discarded Estate x3
      And it should be my Buy phase
    When my next turn starts
      Then the following 2 steps should happen at once
        Then I should have moved Throne Room, Tactician from enduring to play
        And I should have drawn 5 cards
      And I should have 2 actions available
      And I should have 2 buys available

  Scenario:
    Given my hand contains King's Court, Tactician, Estate x3
      And it is my Play Action phase
    When I play King's Court
    And I choose Tactician in my hand
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have played Tactician
        And I should have moved King's Court from play to enduring
        And I should have discarded Estate x3
      And it should be my Buy phase
    When my next turn starts
      Then the following 2 steps should happen at once
        Then I should have moved King's Court, Tactician from enduring to play
        And I should have drawn 5 cards
      And I should have 2 actions available
      And I should have 2 buys available