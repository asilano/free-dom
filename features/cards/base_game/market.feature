Feature: Market
  Draw 1 card, +1 Action, +1 Buy, +1 Cash
    
  Background:
    Given I am a player in a standard game with Market
  
  Scenario: Market should be set up at game start
    Then there should be 10 Market cards in piles
      And there should be 0 Market cards not in piles
  
  Scenario: Playing Market
    Given my hand contains Market and 4 other cards
      And it is my Play Action phase
    When I play Market
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 2 buys available
      And I should have 1 cash
      And it should be my Play Action phase
      
  Scenario: Playing multiple Markets
    Given my hand contains Market, Market and 4 other cards
      And it is my Play Action phase
    When I play Market
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 2 buys available
      And I should have 1 cash
      And it should be my Play Action phase
    When I play Market
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 3 buys available
      And I should have 2 cash
      And it should be my Play Action phase
      