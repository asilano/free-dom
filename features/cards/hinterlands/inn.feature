Feature: Inn
  Draw 2 cards, +2 Actions. Discard 2 cards.
  When you gain this, look through your discard pile (including this), reveal any number of Action cards
  from it, and shuffle them into your deck.

  Background:
    Given I am a player in a standard game with Inn

  Scenario: Inn should be set up at game start
    Then there should be 10 Inn cards in piles
      And there should be 0 Inn cards not in piles
      And the Inn pile should cost 5

  Scenario: Playing Inn
    Given my hand contains Inn, Estate x2, Gold x2
      And my deck contains Silver x4
      And it is my Play Action phase
    When I play Inn
      Then I should have drawn 2 cards
      And I should need to Discard 2 cards
      And I should not be able to choose a nil action in my hand
    When I choose Estate in my hand
      Then I should have discarded Estate
      And I should need to Discard 1 card
      And I should not be able to choose a nil action in my hand
    When I choose Silver in my hand
      Then I should have discarded Silver
      And it should be my Play Action phase
      And I should have 2 actions available

  Scenario: Playing Inn with only one kind of card in hand auto-discards 2 of them
    Given my hand contains Inn, Gold x4
      And my deck contains Gold x5
      And it is my Play Action phase
    When I play Inn
      Then the following 2 steps should happen at once
        Then I should have drawn 2 cards
        And I should have discarded Gold, Gold
      And it should be my Play Action phase
      And I should have 2 actions available

  Scenario: Playing Inn with small deck and full discard causes reshuffle
    Given my hand contains Inn, Gold x4
      And my deck contains Gold
      And I have Gold x4 in my discard
      And it is my Play Action phase
    When I play Inn
      Then the following 3 steps should happen at once
        Then I should have drawn 2 cards
        And I should have shuffled my discards
        And I should have discarded Gold, Gold
      And it should be my Play Action phase
      And I should have 2 actions available

  Scenario: Playing Inn with small deck and no discard draws as many as possible
    Given my hand contains Inn
      And my deck contains Gold
      And I have nothing in my discard
      And it is my Play Action phase
    When I play Inn
      Then the following 3 steps should happen at once
        Then I should have drawn 1 card
        And I should have shuffled my discards
        And I should have discarded Gold
    Then it should be my Play Action phase
      And I should have 2 actions available

  Scenario: Playing Inn with not enough cards to discard afterwards (auto-discard)
    Given my hand contains Inn, Estate
      And my deck is empty
      And I have nothing in my discard
      And it is my Play Action phase
    When I play Inn
      Then I should have discarded Estate
    Then it should be my Play Action phase
      And I should have 2 actions available

  Scenario Outline: Gaining Inn
    Given my hand contains Woodcutter, Gold
      And I have Copper, Estate, Nobles, Smithy, Witch in discard
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Gold
    When I buy Inn
    And the game checks actions
      Then I should have gained Inn
      And I should need to Shuffle discarded actions into deck
      And I should have seen Nobles, Smithy, Witch, Inn
    When I choose my peeked <choice>
      Then the following 2 steps should happen at once
        Then I should have moved <choice> from discard to deck
        And I should have shuffled my deck
      And I should need to Buy

  Examples:
  | choice              |
  | Nobles              |
  | Inn                 |
  | Smithy, Witch       |
  | Inn, Nobles, Smithy |

  Scenario: Gaining Inn - Choose nothing
    Given my hand contains Woodcutter, Gold
      And I have Copper, Estate, Nobles, Smithy, Witch in discard
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Gold
    When I buy Inn
    And the game checks actions
      Then I should have gained Inn
      And I should need to Shuffle discarded actions into deck
      And I should have seen Nobles, Smithy, Witch, Inn
    When I choose none of my peeked cards
      Then I should have shuffled my deck
      And I should need to Buy

  Scenario: Gaining Inn not via Buy
    Given my hand contains Remodel x2
      And Bob's hand contains Smuggler
      And I have Copper, Estate, Nobles, Smithy, Witch in discard
      And Bob has Silver, Duchy, Great Hall, Village, Forge in discard
      And it is my Play Action phase
    When I play Remodel
    And the game checks actions
      Then I should have removed Remodel from my hand
      And I should need to Take a replacement card with Remodel
    When I choose the Inn pile
    And the game checks actions
      Then I should have gained Inn
      And I should need to Shuffle discarded actions into deck
      And I should have seen Nobles, Smithy, Witch, Inn
    When I choose my peeked Witch
      Then the following 2 steps should happen at once
        Then I should have moved Witch from discard to deck
        And I should have shuffled my deck
    When the game checks actions
      Then it should be my Buy phase
    When Bob's next turn starts
      Then it should be Bob's Play Action phase
    When Bob plays Smuggler
    And the game checks actions
      Then Bob should have gained Inn
      And Bob should need to Shuffle discarded actions into deck
      And Bob should have seen Great Hall, Village, Forge, Inn
    When Bob chooses his peeked Great Hall, Village
      Then the following 2 steps should happen at once
        Then Bob should have moved Great Hall, Village from discard to deck
        And Bob should have shuffled his deck
    When the game checks actions
      Then it should be Bob's Buy phase