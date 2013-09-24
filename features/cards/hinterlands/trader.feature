Feature: Trader
  Action (Reaction; cost: 4) - Trash a card from your hand. Gain a number of Silvers equal to its cost in coins
    When you would gain a card, you may reveal this from your hand. If you do, instead gain a Silver.

  Background:
    Given I am a player in a standard game with Trader

  Scenario: Trader should be set up at game start
    Then there should be 10 Trader cards in piles
    And there should be 0 Trader cards not in piles
    And the Trader pile should cost 4

  Scenario Outline: Playing Trader
    Given my hand contains Village, Trader, Copper, Estate, Silver, Colony
      And it is my Play Action phase
      And my deck is empty
    When I play Village
    And I play Trader
      Then I should need to Trash a card with Trader
    When I choose <card> in my hand
      Then I should have removed <card> from my hand
    When the game checks actions
      And I should have gained Silver x<cost>

    Examples:
    | card   | cost |
    | Copper |   0  |
    | Estate |   2  |
    | Silver |   3  |
    | Colony |  11  |

  Scenario: Playing Trader, autotrashes only choice
    Given my hand contains Trader, Estate x3
      And it is my Play Action phase
    When I play Trader
      Then I should have removed Estate from my hand
    When the game checks actions
      And I should have gained Silver x2

  Scenario: Playing Trader, nothing to trash
    Given my hand contains Trader
      And it is my Play Action phase
    When I play Trader
      Then nothing should have happened
      And it should be my Play Treasure phase

  Scenario Outline: Reacting with Trader, gain from buy
    Given my hand contains Trader, Woodcutter, Silver
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Silver
    When I buy Estate
    And the game checks actions
      Then I should need to Choose whether to react with Trader
    When I choose the option <opt>
    And the game checks actions
      Then I should have gained <card>

    Examples:
    | opt               | card   |
    | Yes - gain Silver | Silver |
    | No - gain Estate  | Estate |

  Scenario Outline: Reacting with Trader, gain from other means
    Given my hand contains Remodel x2, Trader
      And Bob's hand contains Smuggler, Trader
      And it is my Play Action phase
    When I play Remodel
    And I choose Remodel in my hand
    Then I should have removed Remodel from my hand
      And I should need to Take a replacement card with Remodel
    When I choose the Gold pile
      And the game checks actions
      Then I should need to Choose whether to react with Trader
    When I choose the option <opt1>
    And the game checks actions
      Then I should have gained <card1>
      And it should be my Buy phase
    When I buy Copper
    And the game checks actions
    And I choose the option No - gain Copper
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Copper
        And I should have ended my turn
    And Bob plays Smuggler
      Then Bob should need to Take a card with Smuggler
      And Bob should be able to choose the <card1>, Copper pile
      And Bob should not be able to choose the <rejected> pile
    When Bob chooses the Copper pile
      And the game checks actions
      Then Bob should need to Choose whether to react with Trader
    When Bob chooses the option <opt2>
    And the game checks actions
      Then Bob should have gained <card2>

    Examples:
    | opt1              | card1   | rejected | opt2              | card2  |
    | Yes - gain Silver | Silver  | Gold     | No - gain Copper  | Copper |
    | No - gain Gold    | Gold    | Silver   | Yes - gain Silver | Silver |

  Scenario: Gaining Silver, Trader doesn't trigger
    Given my hand contains Trader, Woodcutter, Silver
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Silver
    When I buy Silver
    And the game checks actions
      Then I should have gained Silver