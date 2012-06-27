Feature: City
  Draw 1 card, +2 Actions. 
    If there are one or more empty Supply piles, draw another card. If there are two or more, +1 Cash and +1 Buy.
    
  Background:
    Given I am a player in a standard game with City, Pawn
  
  Scenario: City should be set up at game start
    Then there should be 10 City cards in piles
      And there should be 0 City cards not in piles
  
  Scenario: Playing City - nothing empty
    Given my hand contains City and 4 other cards
      And it is my Play Action phase
    When I play City
    Then I should have drawn 1 card
      And I should have 2 actions available
      And it should be my Play Action phase
      
  Scenario: Playing multiple Cities - nothing empty
    Given my hand contains City, City and 4 other cards
      And it is my Play Action phase
    When I play City
    Then I should have drawn 1 card
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play City
    Then I should have drawn 1 card
      And I should have 3 actions available
      And it should be my Play Action phase
      
  Scenario: Playing City - one empty
    Given my hand contains City and 4 other cards
      And the Estate pile is empty
      And it is my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 2 actions available
      And it should be my Play Action phase
      
  Scenario: Playing multiple Cities - one empty
    Given my hand contains City, City and 4 other cards
      And the Estate pile is empty
      And it is my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 3 actions available
      And it should be my Play Action phase
      
  Scenario: Playing City - two empty
    Given my hand contains City and 4 other cards
      And the Estate pile is empty
      And the Duchy pile is empty
      And it is my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 1 cash
      And I should have 2 buys available
      And I should have 2 actions available
      And it should be my Play Action phase
      
  Scenario: Playing multiple Cities - two empty
    Given my hand contains City, City and 4 other cards
      And the Estate pile is empty
      And the Duchy pile is empty
      And it is my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 1 cash  
      And I should have 2 buys available
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 2 cash
      And I should have 3 buys available
      And I should have 3 actions available
      And it should be my Play Action phase
      
  Scenario: Playing City - three empty
    Given I am a player in a 6-player standard game with City, Moat 
      And my hand contains City and 4 other cards
      And the Estate pile is empty
      And the Duchy pile is empty
      And the Moat pile is empty
      And it is my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 1 cash
      And I should have 2 buys available
      And I should have 2 actions available
      And it should be my Play Action phase
      
  Scenario: Playing multiple Cities - three empty
    Given I am a player in a 6-player standard game with City, Moat 
      And my hand contains City, City and 4 other cards
      And the Estate pile is empty
      And the Duchy pile is empty
      And the Moat pile is empty
      And it is my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 1 cash  
      And I should have 2 buys available
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play City
    Then I should have drawn 2 cards
      And I should have 2 cash
      And I should have 3 buys available
      And I should have 3 actions available
      And it should be my Play Action phase