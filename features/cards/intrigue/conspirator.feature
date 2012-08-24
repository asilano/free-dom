Feature: Conspirator
  +2 Cash. If you've played 3 or more Actions this turn, +1 Action, draw 1 card.
  
  Background:
    Given I am a player in a standard game with Conspirator
    
  Scenario: Conspirator should be set up at game start
    Then there should be 10 Conspirator cards in piles
      And there should be 0 Conspirator cards not in piles
      
  Scenario: Playing Conspirator as first action
    Given my hand contains Conspirator and 4 other cards
      And it is my Play Action phase
    When I play Conspirator
    Then I should have 2 cash
      And it should be my Play Treasure phase
      
  Scenario: Playing Conspirator as second action
    Given my hand contains Conspirator, Great Hall and 3 other cards
      And it is my Play Action phase
    When I play Great Hall
    Then I should have drawn 1 card
    When I play Conspirator
    Then I should have 2 cash
      And it should be my Play Treasure phase
      
  Scenario: Playing Conspirator as third action
    Given my hand contains Conspirator, Great Hall x2 and 2 other cards
      And it is my Play Action phase
    When I play Great Hall
    Then I should have drawn 1 card
    When I play Great Hall
    Then I should have drawn 1 card
    When I play Conspirator
    Then I should have drawn 1 card
      And I should have 2 cash
      And it should be my Play Action phase
      And I should have 1 action available