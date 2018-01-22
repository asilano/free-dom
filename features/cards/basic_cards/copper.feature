Feature: Copper
  In order for Copper to be correctly coded
  Playing Copper as Treasure
  Should be worth 1 cash

  Background:
    Given I am a player in a standard game

  Scenario: Copper should be set up at game start
    # Standard game has 3 players
    Then there should be 39 Copper cards in piles
    And there should be 21 Copper cards in hands, decks
    And there should be 0 Copper cards not in piles, hands, decks

  Scenario: Copper should be a treasure worth 1 cash
    Given my hand contains Copper, Duchy, Duchy, Duchy, Duchy
      And I have nothing in play
      And it is my Play Treasure phase
    When I play Copper as treasure
    Then I should have 1 cash
      And it should be my Buy phase

  Scenario: Copper should be limited in quantity - gain
    Given I have nothing in discard
    Then there should be 39 Copper cards in piles
    When I gain Copper
    Then I should have gained Copper
      And there should be 38 Copper cards in piles
