Feature: Village
  Draw 1 card, +2 Actions
    
  Background:
    Given I am a player in a standard game with Village
  
  Scenario: Village should be set up at game start
    Then there should be 10 Village cards in piles
      And there should be 0 Village cards not in piles
  
  Scenario: Playing Village
    Given my hand contains Village and 4 other cards
      And it is my Play Action phase
    When I play Village
    Then I should have drawn 1 card
      And I should have 2 actions available
      And it should be my Play Action phase
      
  Scenario: Playing multiple Villages
    Given my hand contains Village, Village and 4 other cards
      And it is my Play Action phase
    When I play Village
    Then I should have drawn 1 card
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play Village
    Then I should have drawn 1 card
      And I should have 3 actions available
      And it should be my Play Action phase
      
