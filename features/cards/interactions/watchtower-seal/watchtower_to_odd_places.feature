Feature: Watchtower applying to cards gained to odd places
  If a card is to be gained other than to discard, Watchtower should provide the options:
    * To top of deck
    * Trash
    * To original target location

  Background:
    Given I am a player in a 2-player standard game

  Scenario Outline: Sea Hag - to-deck gains don't get the To Deck option
    Given my hand contains Watchtower
      And my deck contains Copper x2
      And Bob's hand contains Sea Hag
      And it is Bob's Play Action phase
    When Bob plays Sea Hag
    And the game checks actions
      Then I should have moved Copper from deck to discard
      And I should need to Decide on destination for Curse
    When I choose the option <option>
      Then <result>

    Examples:
    | option              | result                                    |
    | Yes - trash Curse   | nothing should have happened              |
    | No - Curse to deck  | I should have put Curse on top of my deck |

  Scenario Outline: Torturer
    Given my hand contains Watchtower
      And my deck contains Copper x2
      And Bob's hand contains Torturer
      And it is Bob's Play Action phase
    When Bob plays Torturer
      Then Bob should have drawn 3 cards
    When the game checks actions
    And I choose the option Gain a Curse
    And the game checks actions
      Then I should need to Decide on destination for Curse
    When I choose the option <option>
      Then <result>

    Examples:
    | option              | result                                    |
    | Yes - trash Curse   | nothing should have happened              |
    | Yes - Curse on deck | I should have put Curse on top of my deck |
    | No - Curse to hand  | I should have placed Curse in my hand     |