Feature: Peddler
  Draw a card, +1 Action, +1 Cash.
    During your Buy phase, this costs 2 less per Action card you have in play, but not less than 0.

  Background:
    Given I am a player in a standard game with Peddler

  Scenario: Peddler should be set up at game start
    Then there should be 10 Peddler cards in piles
      And there should be 0 Peddler cards not in piles

  Scenario: Playing Peddler
    Given my hand contains Peddler and 4 other cards
      And it is my Play Action phase
    When I play Peddler
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash
      And it should be my Play Action phase

  Scenario: Playing multiple Peddlers
    Given my hand contains Peddler x2 and 4 other cards
      And it is my Play Action phase
    When I play Peddler
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash
      And it should be my Play Action phase
    When I play Peddler
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 2 cash
      And it should be my Play Action phase

  Scenario Outline: Cost of buying Peddler
    Given my hand is empty
      And I have <in_play> in play
      And it is my Buy phase
    Then the Peddler pile should cost <cost>

  Examples:
  | in_play                        | cost |
  | nothing                        |   8  |
  | Smithy                         |   6  |
  | Smithy, Moat                   |   4  |
  | Great Hall, Island, Lighthouse |   2  |
  | Copper, Harem, Duchy           |   8  |
  | Pawn x4                        |   0  |
  | Pawn x5                        |   0  |

  Scenario: Cost of Peddler is unchanged outside of Buy
    # Remember that BUY starts with Play Treasures
    Given my hand contains Bank
      And I have Pawn x3 in play
      And it is my Play Action phase
    Then the Peddler pile should cost 8
    When I stop playing actions
    Then the Peddler pile should cost 8
    When the game checks actions
    Then the Peddler pile should cost 2
    When I play Bank as treasure
    Then the Peddler pile should cost 2