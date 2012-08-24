Feature: Monument
  +2 Cash, +1 VP
    
  Background:
    Given I am a player in a standard game with Monument
  
  Scenario: Monument should be set up at game start
    Then there should be 10 Monument cards in piles
      And there should be 0 Monument cards not in piles
  
  Scenario: Playing Monument
    Given my hand contains Monument and 4 other cards
      And it is my Play Action phase
    When I play Monument
    Then I should have 2 cash
      And my score should be 1
      And it should be my Play Treasure phase
      
  Scenario: Playing multiple Monuments
    Given my hand contains Village, Monument x2 and 4 other cards
      And it is my Play Action phase
    When I play Village
    Then I should have drawn 1 card
    When I play Monument
    Then I should have 2 cash
      And my score should be 1
      And it should be my Play Action phase
    When I play Monument
    Then I should have 4 cash
      And my score should be 2
      And it should be my Play Treasure phase
      
