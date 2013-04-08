Feature: Counting House
  Look through your discard pile, reveal any number of Copper cards from it, and put them into your hand

  Background:
    Given I am a player in a standard game with Counting House

  Scenario: Counting House should be set up at game start
    Then there should be 10 Counting House cards in piles
      And there should be 0 Counting House cards not in piles

  Scenario Outline: Playing Counting House with some Copper
    Given my hand contains Counting House
      And I have <discard> in discard
    When I play Counting House
    Then I should need to Choose the number of Coppers to return with Counting House
      And I should be able to choose exactly <choices> from the dropdown
    When I choose <choice> from the dropdown
    Then I should have moved Copper x<choice> from discard to hand
      And it should be my Play Treasure phase

  Examples:
  | discard                               | choices     | choice |
  | Copper x3                             |  0, 1, 2, 3 |   2    |
  | Copper x3                             |  0, 1, 2, 3 |   0    |
  | Curse, Copper, Estate, Silver, Copper |  0, 1, 2    |   2    |

  Scenario: Playing Counting House with no Copper
    Given my hand contains Counting House
      And I have Curse, Estate, Silver in discard
    When I play Counting House
    Then it should be my Play Treasure phase
