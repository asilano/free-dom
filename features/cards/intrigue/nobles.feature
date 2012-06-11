Feature: Nobles
  Action - Choose one: Draw 3 cards; or +2 Actions
  Victory - 2 point
  
  Scenario Outline: Nobles should be set up at game start
    Given I am a player in a <num>-player standard game with Nobles
    Then there should be <pile count> Nobles cards in piles
      And there should be 0 Nobles cards not in piles
      
    Examples:
      | num | pile count | 
      |  2  |     8      |  
      |  3  |    12      |  
      |  4  |    12      | 
      |  5  |    12      |  
      |  6  |    12      | 
      
  Scenario: Nobles should be worth 2 point
    Given I am a player in a standard game
      And my hand is empty
      And my deck contains Nobles
    When the game ends
    Then my score should be 2
    
  Scenario: Nobles should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Nobles
      And my deck contains Nobles
      And I have Nobles in discard
      And I have Nobles in play
    When the game ends
    Then my score should be 8
    
  Scenario: Playing Nobles - draw cards
    Given I am a player in a standard game
      And my hand contains Nobles and 4 other cards
      And it is my Play Action phase
    When I play Nobles
    Then I should need to Choose Nobles' effect
    When I choose the option Draw three
    Then I should have drawn 3 cards
      And it should be my Play Treasure phase

  Scenario: Playing Nobles - gain actions
    Given I am a player in a standard game
      And my hand contains Nobles and 4 other cards
      And it is my Play Action phase
    When I play Nobles
    Then I should need to Choose Nobles' effect
    When I choose the option Two actions
    Then I should have 2 actions available
      And it should be my Play Action phase
  
  Scenario: Playing multiple Nobless
    Given I am a player in a standard game
      And my hand contains Nobles x3 and 4 other cards
      And it is my Play Action phase
    When I play Nobles
    Then I should need to Choose Nobles' effect
    When I choose the option Two actions
    Then I should have 2 actions available
      And it should be my Play Action phase
    When I play Nobles
    Then I should need to Choose Nobles' effect
    When I choose the option Two actions
    Then I should have 3 action available
      And it should be my Play Action phase
    When I play Nobles
    Then I should need to Choose Nobles' effect
    When I choose the option Draw three
    Then I should have drawn 3 cards
      And I should have 2 actions available
      And it should be my Play Action phase