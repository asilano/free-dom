Feature: Estate
  In order for Estate to be correctly coded
  
  Scenario Outline: Estate should be set up at game start
    Given I am a player in a <num>-player standard game 
    Then there should be <pile count> Estate cards in piles
      And there should be <ply count> Estate cards in hands, decks
      And there should be 0 Estate cards not in piles, hands, decks
      
    Examples:
      | num | pile count | ply count |
      |  2  |     8      |    6      |
      |  3  |    12      |    9      |
      |  4  |    12      |   12      |
      |  5  |    12      |   15      |
      |  6  |    12      |   18      |
      
  Scenario: Estate should be worth 1 point
    Given I am a player in a standard game
      And my hand is empty
      And my deck contains Estate
    When the game ends
    Then my score should be 1
    
  Scenario: Estate should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Estate
      And my deck contains Estate
      And I have Estate in discard
      And I have Estate in play
    When the game ends
    Then my score should be 4