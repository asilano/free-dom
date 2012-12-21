Feature: Scheme
  Draw 1 card, +1 Action. At the start of Clean-up this turn, you may choose an Action card you have in play.
  If you discard it from play this turn, put it on your deck.

  Background:
    Given I am a player in a standard game with Scheme

  Scenario: Scheme should be set up at game start
    Then there should be 10 Scheme cards in piles
    And there should be 0 Scheme cards not in piles
    And the Scheme pile should cost 3