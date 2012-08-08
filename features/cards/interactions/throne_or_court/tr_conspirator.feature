Feature: Conspirator
  Throning a Conspirator should give you the draw + action once
  KC'ing it should give you it twice
    (TR is 1 action, first Cons is 2, second Cons is 3)
  
  Background:
    Given I am a player in a standard game
    
  Scenario: Throne Room
    Given my hand contains Throne Room, Conspirator
      And it is my Play Action phase
    When I play Throne Room
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have played Conspirator
        And I should have drawn a card
      And I should have 4 cash
      And it should be my Play Action phase
      And I should have 1 action available
      
  Scenario: King's Court
    Given my hand contains King's Court, Conspirator
      And it is my Play Action phase
    When I play King's Court
    And I choose Conspirator in my hand
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have played Conspirator
        And I should have drawn 2 cards
      And I should have 6 cash
      And it should be my Play Action phase
      And I should have 2 actions available