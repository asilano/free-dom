Feature: Gold
  In order for Gold to be correctly coded
  Playing Gold as Treasure
  Should be worth 3 cash

  Background:
    Given I am a player in a standard game

  Scenario: Gold should be set up at game start
    Then there should be 30 Gold cards in piles
      And there should be 0 Gold cards not in piles

  Scenario: Gold should be a treasure worth 3 cash
    Given my hand contains Gold, Duchy, Duchy, Duchy, Duchy
      And I have nothing in play
      And it is my Play Treasure phase
    When I play Gold as treasure
    Then I should have 3 cash
      And it should be my Buy phase

  Scenario: Gold should be limited in quantity - gain
    Given I have nothing in discard
    Then there should be 30 Gold cards in piles
    When I gain Gold
    Then I should have gained Gold
      And there should be 29 Gold cards in piles
