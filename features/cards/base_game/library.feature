Feature: Library
  Draw until you have 7 cards in hand. 
  You may set aside any Action cards you draw this way, as you draw them; discard the set-aside cards after you finish drawing.
  
  Background:
    Given I am a player in a standard game with Library
    
  Scenario: Library should be set up at game start
    Then there should be 10 Library cards in piles
      And there should be 0 Library cards not in piles
    
  Scenario Outline: Playing Library with no actions, and various hand sizes
    Given my hand contains Library and <num> other cards
      And my deck contains <deck>
      And it is my Play Action phase
    When I play Library
    Then I should have drawn <drawn> cards
      And it should be my Play Treasure phase
      
    Examples:
      | num | deck       | drawn |
      |  0  | Copper x10 |   7   |
      |  2  | Copper x10 |   5   |
      |  7  | Copper x10 |   0   |
      |  9  | Copper x10 |   0   |
      |  2  | Copper x 3 |   3   |
    