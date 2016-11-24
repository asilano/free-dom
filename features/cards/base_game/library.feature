Feature: Library
  Draw until you have 7 cards in hand.
  You may set aside any Action cards you draw this way, as you draw them; discard the set-aside cards after you finish drawing.

  Background:
    Given I am a player in a standard game with Library

  Scenario: Library should be set up at game start
    Then there should be 10 Library cards in piles
      And there should be 0 Library cards not in piles

  Scenario Outline: Playing Library with no actions, and various hand sizes
    Given my hand contains Library and <num> other cards
      And my deck contains <deck>
      And it is my Play Action phase
    When I play Library
    Then I should have drawn <drawn> cards
      And it should be my Play Treasure phase

    Examples:
      | num | deck       | drawn |
      |  0  | Copper x10 |   7   |
      |  2  | Copper x10 |   5   |
      |  7  | Copper x10 |   0   |
      |  9  | Copper x10 |   0   |
      |  2  | Copper x 3 |   3   |

  Scenario: Playing Library with Actions
  Given my hand contains Library and 2 other cards
      And my deck contains Copper x2, Smithy, Copper x1, Witch, Mine, Copper
      And it is my Play Action phase
    When I play Library
    Then I should have drawn 3 cards
      And I should need to Set aside or keep a card with Library.
    When I choose Smithy in my hand
    Then the following 2 steps should happen at once
      Then I should have removed Smithy from my hand
      And I should have drawn 2 cards
    And I should need to Set aside or keep a card with Library.
    When I choose Witch in my hand
    Then the following 2 steps should happen at once
      Then I should have removed Witch from my hand
      And I should have drawn 1 card
    And I should need to Set aside or keep a card with Library.
    When I choose Keep in my hand
    Then the following 2 steps should happen at once
      Then I should have drawn 1 card
      And I should have placed Smithy, Witch in my discard