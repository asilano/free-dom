Feature: Bridge-Trader
  Trader should grant Silvers equal to the Bridge-adjusted cost of cards.

  Background:
    Given I am a player in a standard game

  Scenario Outline: Playing Trader after Bridge
    Given my hand contains Village x2, Bridge, Trader, Copper, Estate, Silver, Colony
      And it is my Play Action phase
      And my deck is empty
    When I play Village
    And I play Village
    And I play Bridge
    And I play Trader
      Then I should need to Trash a card with Trader
    When I choose <card> in my hand
      Then I should have removed <card> from my hand
    When the game checks actions
      And I should have gained Silver x<cost>

    Examples:
    | card   | cost |
    | Copper |   0  |
    | Estate |   1  |
    | Silver |   2  |
    | Colony |  10  |
