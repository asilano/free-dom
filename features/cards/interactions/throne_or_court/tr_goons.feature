Feature: Throne Room + Goons
  TR into Goons, then one Buy should give 1VP, not 2.
    
  Background:
    Given I am a player in a standard game with Throne Room, Goons, Pawn

  Scenario:
    Given my hand contains Goons, Throne Room
      And Bob's hand is empty
      And Charlie's hand is empty
      And it is my Play Action phase
    When I play Throne Room
    And the game checks actions
      Then I should have played Goons
      And I should have 4 cash    
      And it should be my Buy phase
      And I should have 3 buys available    
    When I buy Pawn
    Then my score should be 1
    When the game checks actions
    Then I should have gained Pawn
      And it should be my Buy phase