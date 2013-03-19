Feature: Watchtower
  Draw until you have 6 cards in hand.
  Reaction - When you gain a card, you may reveal this from your hand. If you do, either trash that card, or put it on top of your deck.

  Background:
    Given I am a player in a standard game with Watchtower, Pawn

  Scenario: Watchtower should be set up at game start
    Then there should be 10 Watchtower cards in piles
      And there should be 0 Watchtower cards not in piles

  Scenario Outline: Playing Watchtower with various hand sizes
    Given my hand contains Watchtower and <num> other cards
      And my deck contains <deck>
      And it is my Play Action phase
    When I play Watchtower
    Then I should have drawn <drawn> cards
      And it should be my Play Treasure phase

    Examples:
      | num | deck       | drawn |
      |  0  | Copper x10 |   6   |
      |  2  | Copper x10 |   4   |
      |  6  | Copper x10 |   0   |
      |  9  | Copper x10 |   0   |
      |  2  | Copper x 3 |   3   |

  Scenario Outline: Reacting with Watchtower - gain due to buy
    Given my hand contains Watchtower, Gold
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold
      And it should be my Buy phase
    When I buy Silver
    And the game checks actions
      Then I should need to Decide on destination for Silver
    Then dump actions
    When I choose the option <choice>
      Then <result>

    Examples:
      | choice                  | result                                     |
      | No - Silver to discard  | I should have gained Silver                |
      | Yes - Silver on deck    | I should have put Silver on top of my deck |
      | Yes - trash Silver      | nothing should have happened               |

  Scenario Outline: Reacting with Watchtower - gain due to action
    Given my hand contains Watchtower, Remodel, Copper
      And it is my Play Action phase
    When I play Remodel
    And I choose Copper in my hand
      Then I should have removed Copper from my hand
    When I choose the Pawn pile
    And the game checks actions
      Then I should need to Decide on destination for Pawn
    When I choose the option <choice>
      Then <result>

    Examples:
      | choice                | result                                   |
      | No - Pawn to discard  | I should have gained Pawn                |
      | Yes - Pawn on deck    | I should have put Pawn on top of my deck |
      | Yes - trash Pawn      | nothing should have happened             |

  Scenario Outline: Recating with Watchtower - gain due to attack
    Given my hand contains Watchtower, Gold
      And Bob's hand contains Witch
      And Charlie has Lighthouse as a duration
      And it is Bob's Play Action phase
    When Bob plays Witch
      Then Bob should have drawn 2 cards
    When the game checks actions
      Then I should need to Decide on destination for Curse
    When I choose the option <choice>
      Then <result>

    Examples:
      | choice                 | result                                    |
      | No - Curse to discard  | I should have gained Curse                |
      | Yes - Curse on deck    | I should have put Curse on top of my deck |
      | Yes - trash Curse      | nothing should have happened              |