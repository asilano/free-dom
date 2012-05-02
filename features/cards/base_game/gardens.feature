Feature: Gardens
  Victory - Worth 1 point per 10 cards in deck, rounded down.
  
  Scenario Outline: Gardens should be set up at game start
    Given I am a player in a <num>-player standard game with Gardens
    Then there should be <pile count> Gardens cards in piles
      And there should be 0 Gardens cards not in piles
      
    Examples:
      | num | pile count |
      |  2  |     8      |
      |  3  |    12      |
      |  4  |    12      |
      |  5  |    12      |
      |  6  |    12      |
      
  Scenario Outline: Gardens should be worth cards/10 points in any zone
    Given I am a player in a standard game with Gardens
      And my hand contains Gardens, Copper x<hand>
      And my deck contains Copper x<deck>
      And I have Copper x<discard> in discard      
      And I have Lighthouse x<enduring> as durations
    When the game ends
    Then my score should be <score>
    
    Examples:
     | hand | deck | discard | enduring | score |
     |   0  |  0   |    0    |     0    |   0   |
     |   9  |  0   |    0    |     0    |   1   |
     |   9  | 10   |    0    |     0    |   2   |
     |   4  |  2   |   15    |     0    |   2   |
     |   0  | 23   |    4    |     2    |   3   |
    
  Scenario: Gardens should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Gardens, Copper x10
      And my deck contains Gardens
      And I have Gardens in discard
      And I have Gardens in play
    When the game ends
    Then my score should be 4
