Feature: Spice Merchant
  You may trash a Treasure from your hand. If you do, choose one: Draw 2 cards, +1 Action; or +2 cash, +1 Buy

  Background:
    Given I am a player in a standard game with Spice Merchant

  Scenario: Spice Merchant should be set up at game start
    Then there should be 10 Spice Merchant cards in piles
      And there should be 0 Spice Merchant cards not in piles
      And the Spice Merchant pile should cost 4

  Scenario Outline: Playing Spice Merchant and trashing
    Given my hand contains Village, Spice Merchant, Copper, Silver
      And my deck contains Estate x4
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
      And I should have 2 actions available
    When I play Spice Merchant
      Then I should need to Trash a Treasure card with Spice Merchant
      And I should be able to choose Copper, Silver in my hand
      And I should not be able to choose Estate in my hand
    When I choose Copper in my hand
      Then I should have removed Copper from my hand
      Then I should need to Choose Spice Merchant's benefit
    When I choose the option <option>
      Then I should have drawn <draw> cards
      And I should have <actions> actions available
      And I should have <cash> cash
      And I should have <buys> buys available
      And it should be my Play Action phase

    Examples:
    | option            | draw | actions | cash | buys |
    | 2 Cards, 1 Action |  2   |   2     |  0   |  1   |
    | 2 Cash, 1 Buy     |  0   |   1     |  2   |  2   |

  Scenario: Playing Spice Merchant, no trash
    Given my hand contains Village, Spice Merchant, Copper, Silver
      And my deck contains Estate x4
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
      And I should have 2 actions available
    When I play Spice Merchant
      Then I should need to Trash a Treasure card with Spice Merchant
    When I choose Trash nothing in my hand
      Then it should be my Play Action phase

  Scenario: Playing Spice Merchant, can't trash
    Given my hand contains Village, Spice Merchant
      And my deck contains Estate x4
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
      And I should have 2 actions available
    When I play Spice Merchant
      Then it should be my Play Action phase
