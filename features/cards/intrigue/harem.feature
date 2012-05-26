Feature: Harem
  Treasure - 2 cash
  Victory - s points
  
  Scenario Outline: Harem should be set up at game start
    Given I am a player in a <num>-player standard game with Harem
    Then there should be <pile count> Harem cards in piles
      And there should be 0 Harem cards not in piles
      
    Examples:
      | num | pile count | 
      |  2  |     8      |  
      |  3  |    12      |  
      |  4  |    12      | 
      |  5  |    12      |  
      |  6  |    12      | 
      
  Scenario: Harem should be worth 2 points
    Given I am a player in a standard game with Harem
      And my hand is empty
      And my deck contains Harem
    When the game ends
    Then my score should be 2
    
  Scenario: Harem should contribute to score from all zones
    Given I am a player in a standard game with Harem
      And my hand contains Harem
      And my deck contains Harem
      And I have Harem in discard
      And I have Harem in play
    When the game ends
    Then my score should be 8
    
  Scenario: Harem should be a treasure worth 2 cash
    Given I am a player in a standard game with Harem
      And my hand contains Harem, Duchy, Duchy, Duchy, Duchy
      And I have nothing in play
      And it is my Play Treasure phase
    When the game checks actions
    Then I should have played Harem
      And I should have 2 cash
      And it should be my Buy phase