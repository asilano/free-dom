Feature: Gold
  In order for Gold to be correctly coded
  Playing Gold as Treasure
  Should be worth 3 cash
  
  Background:
    Given I am a player in a standard game
  
  Scenario: Gold should be set up at game start
    Then there should be 10 Gold cards in piles
      And there should be 0 Gold cards not in piles
    
  Scenario: Gold should be a treasure worth 3 cash
    Given my hand contains Gold, Duchy, Duchy, Duchy, Duchy
      And I have nothing in play
      And it's my Play Treasure phase
    When the game checks actions
    Then I should have only Gold in play
      And I should have 3 cash
      And it should be my Buy phase
    
  Scenario: Gold should be unlimited in quantity - gain
    Given I have nothing in discard
    Then there should be 10 Gold cards in piles
    When I gain Gold
    Then I should have only Gold in discard
      And there should be 10 Gold cards in piles
      
  Scenario: Gold should be unlimited in quantity - return
    Given my hand contains Gold
    Then there should be 10 Gold cards in piles
    When I move Gold from hand to pile
    Then I should not have Gold in hand
      And there should be 10 Gold cards in piles