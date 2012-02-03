Feature: Duchy
  In order for Duchy to be correctly coded
  
  Scenario Outline: Duchy should be set up at game start
    Given I am a player in a <num>-player standard game 
    Then there should be <pile count> Duchy cards in piles
      And there should be 0 Duchy cards not in piles
      
    Examples:
      | num | pile count |
      |  2  |     8      |
      |  3  |    12      |
      |  4  |    12      |
      |  5  |    12      |
      |  6  |    12      |
      
  Scenario: Duchy should be worth 3 points
    Given I am a player in a standard game
      And my hand is empty
      And my deck contains Duchy
    When the game ends
    Then my score should be 3
    
  Scenario: Duchy should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Duchy
      And my deck contains Duchy
      And I have Duchy in discard
      And I have Duchy in play
    When the game ends
    Then my score should be 12