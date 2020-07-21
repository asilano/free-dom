# Victory (cost: 4) - Worth 1 point per 10 cards you have (round down).
Feature: Festival
  Background:
    Given I am in a 3 player game

  Scenario Outline: Worth floor(deck-size) points
    Given my hand contains nothing
    And my deck contains Gardens x<Gardens>, Copper x<Copper>
    Then my total score should be <Score>
    Examples:
      | Gardens | Copper | Score |
      |     1   |    8   |   0   |
      |     1   |    9   |   1   |
      |     1   |   20   |   2   |
      |     2   |    8   |   2   |
      |     5   |   38   |  20   |
