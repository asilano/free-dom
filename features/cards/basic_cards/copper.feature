Feature: Copper
  In order for Copper to be correctly coded
  Playing Copper as Treasure
  Should be worth 1 cash
  
  Background:
    Given I am a player in a standard game
  
  Scenario: Copper should be set up at game start
    Then there should be 10 Copper cards in piles
      # Standard game has 3 players
      And there should be 21 Copper cards in hands, decks  
      And there should be 0 Copper cards not in piles, hands, decks
    
  Scenario: Copper should be a treasure worth 1 cash
    Given my hand contains Copper, Duchy, Duchy, Duchy, Duchy
      And I have nothing in play
      And it's my Play Treasure phase
    When the game checks actions
    Then I should have played Copper
      And I should have 1 cash
      And it should be my Buy phase
    
  Scenario: Copper should be unlimited in quantity - gain
    Given I have nothing in discard
    Then there should be 10 Copper cards in piles
    When I gain Copper
    Then I should have gained Copper
      And there should be 10 Copper cards in piles
      
  Scenario: Copper should be unlimited in quantity - return
    Given my hand contains Copper
    Then there should be 10 Copper cards in piles
    When I move Copper from hand to pile
    Then there should be 10 Copper cards in piles