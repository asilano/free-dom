Feature: Noble Brigand
  +1 Coin
  When you buy this or play it, each other player reveals the top 2 cards of his deck,
  trashes a revealed Silver or Gold you choose, and discards the rest.
  If he didn't reveal a Treasure, he gains a Copper. You gain the trashed cards.

  Background:
    Given I am a player in a standard game with Noble Brigand

  Scenario: Noble Brigand should be set up at game start
    Then there should be 10 Noble Brigand cards in piles
      And there should be 0 Noble Brigand cards not in piles
      And the Noble Brigand pile should cost 4