Feature: Silver
  In order for Silver to be correctly coded
  Playing Silver as Treasure
  Should be worth 2 cash
  
  Background:
    Given I am a player in a standard game
  
  Scenario: Silver should be set up at game start
    Then there should be 10 Silver cards in piles
      And there should be 0 Silver cards not in piles
    
  Scenario: Silver should be a treasure worth 2 cash
    Given my hand contains Silver, Duchy, Duchy, Duchy, Duchy
      And I have nothing in play
      And it is my Play Treasure phase
    When the game checks actions
    Then I should have played Silver
      And I should have 2 cash
      And it should be my Buy phase
    
  Scenario: Silver should be unlimited in quantity - gain
    Given I have nothing in discard
    Then there should be 10 Silver cards in piles
    When I gain Silver
    Then I should have gained Silver
      And there should be 10 Silver cards in piles
      
  Scenario: Silver should be unlimited in quantity - return
    Given my hand contains Silver
    Then there should be 10 Silver cards in piles
    When I move Silver from hand to pile
    Then there should be 10 Silver cards in piles