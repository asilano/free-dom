Feature: Duke
  Victory - Worth 1 point per Duchy in your deck
  
  Scenario Outline: Duke should be set up at game start
    Given I am a player in a <num>-player standard game with Duke
    Then there should be <pile count> Duke cards in piles
      And there should be 0 Duke cards not in piles
      
    Examples:
      | num | pile count |
      |  2  |     8      |
      |  3  |    12      |
      |  4  |    12      |
      |  5  |    12      |
      |  6  |    12      |
      
  Scenario Outline: Duke should be worth points==Duchies in any zone
    Given I am a player in a standard game with Duke
      And my hand contains Duke, Duchy x<hand>
      And my deck contains Duchy x<deck>
      And I have Duchy x<discard> in discard      
      And I have Lighthouse x<enduring> as durations
    When the game ends
    Then my score should be <score>
    
    Examples:
     | hand | deck | discard | enduring | score |
     |   0  |  0   |    0    |     0    |   0   |
     |   3  |  0   |    0    |     0    |  12   |
     |   3  |  2   |    0    |     0    |  20   |
     |   4  |  2   |    1    |     0    |  28   |
     |   0  |  3   |    4    |     2    |  28   |
    
  Scenario: Duke should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Duke, Duchy x2
      And my deck contains Duke
      And I have Duke in discard
      And I have Duke in play
    When the game ends
    Then my score should be 14
  
