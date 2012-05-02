Feature: Moneylender
  Trash a Copper card from your hand. If you do, +3 cash.

  Background:
    Given I am a player in a standard game with Moneylender

  Scenario: Moneylender should be set up at start of game
    Then there should be 10 Moneylender cards in piles
      And there should be 0 Moneylender cards not in piles

  Scenario: Playing Moneylender while holding Copper
    Given my hand contains Moneylender, Copper x2, Silver
      And it is my Play Action phase
    When I play Moneylender
    Then I should have removed Copper from hand
      And I should have 3 cash
      And it should be my Play Treasure phase

  Scenario: Playing Moneylender while not holding Copper
    Given my hand contains Moneylender, Estate x2, Silver
      And it is my Play Action phase
    When I play Moneylender
    Then I should have 0 cash
      And it should be my Play Treasure phase
