Feature: Island
  Set aside this and another card from your hand. Return them to your deck at the end of the game. 
  Victory - 2 points
  
  Scenario Outline: Island should be set up at game start
    Given I am a player in a <num>-player standard game with Island
    Then there should be <pile count> Island cards in piles
      And there should be 0 Island cards not in piles
      
    Examples:
      | num | pile count | 
      |  2  |     8      |  
      |  3  |    12      |  
      |  4  |    12      | 
      |  5  |    12      |  
      |  6  |    12      | 
      
  Scenario: Island should be worth 2 points
    Given I am a player in a standard game
      And my hand is empty
      And my deck contains Island
    When the game ends
    Then my score should be 2
    
  Scenario: Island should contribute to score from all normal zones
    Given I am a player in a standard game
      And my hand contains Island
      And my deck contains Island
      And I have Island in discard
      And I have Island in play
    When the game ends
    Then my score should be 8
    
  Scenario: Playing Island; it and other set-aside cards should contribute to score
    Given I am a player in a standard game
      And my hand contains Island, Estate, Copper x3
      And my deck is empty
      And it is my Play Action phase
    When I play Island
      Then I should need to Set a card aside with Island
      And I should not be able to choose a nil action in my hand
    When I choose Estate in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Estate from my hand
        And I should have removed Island from my play
      And it should be my Play Treasure phase
    When the game ends
    Then my score should be 3
      
  Scenario: Playing Island with only one kind of card: auto-choose that card
    Given I am a player in a standard game
      And my hand contains Island, Estate x4
      And my deck is empty
      And it is my Play Action phase
    When I play Island
      Then the following 2 steps should happen at once
        Then I should have removed Estate from my hand
        And I should have removed Island from my play
      And it should be my Play Treasure phase
    When the game ends
    Then my score should be 6
      
  Scenario: Playing Island with no cards left in hand to set aside
    Given I am a player in a standard game
      And my hand contains Island
      And my deck is empty
      And it is my Play Action phase
    When I play Island
      Then I should have removed Island from my play
      And it should be my Play Treasure phase
    When the game ends
    Then my score should be 2
      
  Scenario: Playing multiple Islands
    Given I am a player in a standard game
      And my hand contains Village, Island, Island, Curse, Estate
      And my deck is empty
      And it is my Play Action phase
    When I play Village
    Then I should have drawn 1 card
      And I should have 2 actions available
    When I play Island
      Then I should need to Set a card aside with Island
    When I choose Estate in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Estate from my hand
        And I should have removed Island from my play
      And I should have 1 action available
    When I play Island
      Then the following 2 steps should happen at once
        Then I should have removed Curse from my hand
        And I should have removed Island from my play
      And it should be my Play Treasure phase
    When the game ends
    Then my score should be 4
  
  Scenario: Playing Island with Throne Room
    Given I am a player in a standard game
      And my hand contains Island, Throne Room, Estate, Copper, Curse
      And my deck is empty
      And it is my Play Action phase
    When I play Throne Room
      And the game checks actions
      Then I should have moved Island from hand to play
      And I should need to Set a card aside with Island
    When I choose Estate in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Estate from my hand
        And I should have removed Island from my play
    When the game checks actions
      Then I should need to Set a card aside with Island
    When I choose Curse in my hand
      Then I should have removed Curse from my hand
      And it should be my Play Treasure phase
    When the game ends
    Then my score should be 2
