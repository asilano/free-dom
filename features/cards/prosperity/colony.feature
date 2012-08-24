Feature: Colony
  10 VP
  
  Scenario Outline: Colony should be set up at game start
    Given I am a player in a <num>-player standard game with Colony
    Then there should be <pile count> Colony cards in piles
      And there should be 0 Colony cards not in piles
      
    Examples:
      | num | pile count |
      |  2  |     8      |
      |  3  |    12      |
      |  4  |    12      |
      |  5  |    15      |
      |  6  |    18      |
      
  Scenario: Colony should be worth 10 points
    Given I am a player in a standard game with Colony
      And my hand is empty
      And my deck contains Colony
    When the game ends
    Then my score should be 10
    
  Scenario: Colony should contribute to score from all zones
    Given I am a player in a standard game with Colony
      And my hand contains Colony
      And my deck contains Colony
      And I have Colony in discard
      And I have Colony in play
    When the game ends
    Then my score should be 40
    
  Scenario: Emptying the Colony pile should trip game end
    Given I am a player in a standard game with Colony
      And my hand contains Duchy x5
      And it is my Play Action phase
      And the Colony pile is empty
    When I stop playing actions
      And the game checks actions
      And I stop buying cards
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have discarded Duchy x5
      And I should have drawn 5 cards
    And the game should have ended