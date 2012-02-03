Feature: Curse
  In order for Curse to be correctly coded
  
  Scenario Outline: Curse should be set up at game start
    Given I am a player in a <num>-player standard game 
    Then there should be <pile count> Curse cards in piles
      And there should be 0 Curse cards not in piles
      
    Examples:
      | num | pile count |
      |  2  |    10      |
      |  3  |    20      |
      |  4  |    30      |
      |  5  |    40      |
      |  6  |    50      |
      
  Scenario: Curse should be worth -1 point
    Given I am a player in a standard game
      And my hand is empty
      And my deck contains Curse
    When the game ends
    Then my score should be -1
    
  Scenario: Curse should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Curse
      And my deck contains Curse
      And I have Curse in discard
      And I have Curse in play
    When the game ends
    Then my score should be -4