Feature: Jack of all Trades - Action: 4
  Gain a Silver.
  Look at the top card of your deck; discard it or put it back.
  Draw until you have 5 cards in hand.
  You may trash a card from your hand that is not a Treasure.

  Background:
    Given I am a player in a standard game with Jack of all Trades

  Scenario: Jack of all Trades should be set up at game start
    Then there should be 10 Jack of all Trades cards in piles
      And there should be 0 Jack of all Trades cards not in piles
      And the Jack of all Trades pile should cost 4

  Scenario Outline: Playing Jack of all Trades; top card & trash available
    Given my hand contains Jack of all Trades, <hand_cards>
      And my deck contains <deck_cards>
      And it is my Play Action phase
    When I play Jack of all Trades
    And the game checks actions
      Then I should have gained Silver
      And I should have seen <top_card>
      And I should need to Choose whether to discard <top_card>
    When I choose the option <discard_choice>
      Then <discard_effect>
    When the game checks actions
      Then I should have drawn <num_drawn> cards
      And I should need to Optionally trash a non-treasure
      And I should be able to choose <non_treasures> in my hand
      And I should not be able to choose <treasures> in my hand
    When I choose <trash_choice> in my hand
      Then <trash_effect>

    Examples:
    | hand_cards            | deck_cards            | top_card | discard_choice     | discard_effect                                  | num_drawn | non_treasures         | treasures     | trash_choice  | trash_effect                              |
    | Estate, Copper, Duchy | Estate, Harem, Nobles | Estate   | Discard Estate     | I should have moved Estate from deck to discard | 2         | Estate, Duchy, Nobles | Copper, Harem | Estate        | I should have removed Estate from my hand |
    | Estate, Copper        | Mint, Harem, Nobles   | Mint     | Don't discard Mint | nothing should have happened                    | 3         | Estate, Mint, Nobles  | Copper, Harem | Estate        | I should have removed Estate from my hand |
    | Estate                | Mint, Harem, Nobles   | Mint     | Discard Mint       | I should have moved Mint from deck to discard   | 4         | Estate, Mint, Nobles  | Harem, Silver | Trash nothing | nothing should have happened              |
    | Estate                | Mint                  | Mint     | Don't discard Mint | nothing should have happened                    | 2         | Estate, Mint          | Silver        | Trash nothing | nothing should have happened              |

  Scenario: Playing Jack of all Trades; no trash possible
    Given my hand contains Jack of all Trades, Copper, Bank
      And my deck contains Gold x3
      And it is my Play Action phase
    When I play Jack of all Trades
    And the game checks actions
      Then I should have gained Silver
      And I should have seen Gold
    When I choose the option Don't discard Gold
    And the game checks actions
      Then I should have drawn 3 cards
      And it should be my Play Treasure phase
