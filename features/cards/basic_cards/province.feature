Feature: Province
  In order for Province to be correctly coded
  
  Scenario Outline: Province should be set up at game start
    Given I am a player in a <num>-player standard game 
    Then there should be <pile count> Province cards in piles
      And there should be 0 Province cards not in piles
      
    Examples:
      | num | pile count |
      |  2  |     8      |
      |  3  |    12      |
      |  4  |    12      |
      |  5  |    15      |
      |  6  |    18      |
      
  Scenario: Province should be worth 6 points
    Given I am a player in a standard game
      And my hand is empty
      And my deck contains Province
    When the game ends
    Then my score should be 6
    
  Scenario: Province should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Province
      And my deck contains Province
      And I have Province in discard
      And I have Province in play
    When the game ends
    Then my score should be 24