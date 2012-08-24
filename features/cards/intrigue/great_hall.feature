Feature: Great Hall
  Action - Draw 1 card, +1 Action
  Victory - 1 point
  
  Scenario Outline: Great Hall should be set up at game start
    Given I am a player in a <num>-player standard game with Great Hall
    Then there should be <pile count> Great Hall cards in piles
      And there should be 0 Great Hall cards not in piles
      
    Examples:
      | num | pile count | 
      |  2  |     8      |  
      |  3  |    12      |  
      |  4  |    12      | 
      |  5  |    12      |  
      |  6  |    12      | 
      
  Scenario: Great Hall should be worth 1 point
    Given I am a player in a standard game
      And my hand is empty
      And my deck contains Great Hall
    When the game ends
    Then my score should be 1
    
  Scenario: Great Hall should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Great Hall
      And my deck contains Great Hall
      And I have Great Hall in discard
      And I have Great Hall in play
    When the game ends
    Then my score should be 4
    
  Scenario: Playing Great Hall
    Given I am a player in a standard game
      And my hand contains Great Hall and 4 other cards
      And it is my Play Action phase
    When I play Great Hall
    Then I should have drawn 1 card
      And I should have 1 action available
      And it should be my Play Action phase
      
  Scenario: Playing multiple Great Halls
    Given I am a player in a standard game
      And my hand contains Great Hall, Great Hall and 4 other cards
      And it is my Play Action phase
    When I play Great Hall
    Then I should have drawn 1 card
      And I should have 1 action available
      And it should be my Play Action phase
    When I play Great Hall
    Then I should have drawn 1 card
      And I should have 1 action available
      And it should be my Play Action phase