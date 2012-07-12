Feature: Merchant Ship
  Now and at the start of your next turn: +2 Cash.
  
  Background:
    Given I am a player in a standard game with Merchant Ship
    
  Scenario: Merchant Ship should be set up at game start
    Then there should be 10 Merchant Ship cards in piles
      And there should be 0 Merchant Ship cards not in piles
      
  Scenario: Playing Merchant Ship
    Given my hand contains Merchant Ship, Estate x4
      And it is my Play Action phase
    When I play Merchant Ship
      And the game checks actions
    Then I should have 2 cash
      And it should be my Buy phase
    When my next turn starts
    Then I should have moved Merchant Ship from enduring to play
      And I should have 2 cash
      And I should have 1 action available
