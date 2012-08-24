Feature: Venture
  Treasure - 1 Cash. 
    When you play this, reveal cards from your deck until you reveal a Treasure. Discard the other cards. Play that Treasure.
  
  Background:
    Given I am a player in a standard game with Venture
    
  Scenario: Venture should be set up at game start
    Then there should be 10 Venture cards in piles
      And there should be 0 Venture cards not in piles
      
  Scenario: Playing Venture - finding a simple treasure
    Given my hand contains Venture, Gold x3
      And my deck contains Estate, Smithy, Great Hall, Copper, Moat
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Venture as treasure
      Then the following 2 steps should happen at once
        Then I should have moved Estate, Smithy, Great Hall from deck to discard
        And I should have moved Copper from deck to play
      And I should have 2 cash    
      And I should need to Play Treasure 
      
  Scenario: Playing Venture - finding a special (not Venture) treasure
    Given my hand contains Venture, Gold x3
      And my deck contains Estate, Smithy, Great Hall, Bank, Moat
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Venture as treasure
      Then the following 2 steps should happen at once
        Then I should have moved Estate, Smithy, Great Hall from deck to discard
        And I should have moved Bank from deck to play
      And I should have 3 cash    
      And I should need to Play Treasure 
      
  Scenario: Playing Venture - finding another Venture
    Given my hand contains Venture, Gold x3
      And my deck contains Estate, Smithy, Venture, Great Hall, Silver, Moat
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Venture as treasure
      Then the following 4 steps should happen at once
        Then I should have moved Estate, Smithy from deck to discard
        And I should have moved Venture from deck to play
        And I should have moved Great Hall from deck to discard
        And I should have moved Silver from deck to play
      And I should have 4 cash    
      And I should need to Play Treasure
      
  Scenario: Playing Venture - playing two Ventures
    Given my hand contains Venture, Venture, Gold x3
      And my deck contains Estate, Smithy, Great Hall, Copper, Moat
      And I have Silver, Adventurer, Witch in discard
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Venture as treasure
      Then the following 2 steps should happen at once
        Then I should have moved Estate, Smithy, Great Hall from deck to discard
        And I should have moved Copper from deck to play
      And I should have 2 cash    
      And I should need to Play Treasure 
    When I play Venture as treasure
      Then the following 3 steps should happen at once
        Then I should have shuffled my discards
        And I should have moved Moat, Adventurer, Estate, Great Hall from deck to discard
        And I should have moved Silver from deck to play
      And I should have 5 cash
      And I should need to Play Treasure 
      
  Scenario: Playing Venture - no treasures
    Given my hand contains Venture, Gold x3
      And my deck contains Estate, Smithy, Great Hall
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Venture as treasure
      Then I should have moved Estate, Smithy, Great Hall from deck to discard      
      And I should have 1 cash    
      And I should need to Play Treasure 