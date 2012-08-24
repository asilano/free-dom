Feature: Platinum
  In order for Platinum to be correctly coded
  Playing Platinum as Treasure
  Should be worth 5 cash
  
  Background:
    Given I am a player in a standard game with Platinum
  
  Scenario: Platinum should be set up at game start
    Then there should be 10 Platinum cards in piles
      And there should be 0 Platinum cards not in piles
    
  Scenario: Platinum should be a treasure worth 5 cash
    Given my hand contains Platinum, Duchy, Duchy, Duchy, Duchy
      And I have nothing in play
      And it is my Play Treasure phase
    When the game checks actions
    Then I should have played Platinum
      And I should have 5 cash
      And it should be my Buy phase
    
  Scenario: Platinum should be unlimited in quantity - gain
    Given I have nothing in discard
    Then there should be 10 Platinum cards in piles
    When I gain Platinum
    Then I should have gained Platinum
      And there should be 10 Platinum cards in piles
      
  Scenario: Platinum should be unlimited in quantity - return
    Given my hand contains Platinum
    Then there should be 10 Platinum cards in piles
    When I move Platinum from hand to pile
    Then there should be 10 Platinum cards in piles