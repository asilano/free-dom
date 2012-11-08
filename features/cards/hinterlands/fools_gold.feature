Feature: Fool's Gold - Treasure/Reaction: 2
  If this is the first time you played a Fool's Gold this turn, this is worth 1 coin, otherwise it's worth 4 coins.
  ----------------------
  When another player gains a Province, you may trash this from your hand. If you do, gain a Gold, putting it on your deck.

  Background:
    Given I am a player in a standard game with Fool's Gold

  Scenario: Fool's Gold should be set up at game start
    Then there should be 10 Fool's Gold cards in piles
      And there should be 0 Fool's Gold cards not in piles
      And the Fool's Gold pile should cost 2

  Scenario: Playing Fool's Gold as first and second treasure
    Given my hand contains Fool's Gold x2, Copper
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Fool's Gold as treasure
      Then I should have 1 cash
      And I should need to Play Treasure
    When I play Fool's Gold as treasure
      Then I should have 5 cash
      And I should need to play treasure

  Scenario: Playing Fool's Gold as second, fourth and fifth treasures
    Given my hand contains Fool's Gold x3, Copper x2
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Copper as treasure
    And I play Fool's Gold as treasure
      Then I should have 2 cash
      And I should need to Play Treasure
    When I play Copper as treasure
    And I play Fool's Gold as treasure
      Then I should have 7 cash
      And I should need to play treasure
    When I play Fool's Gold as treasure
      Then I should have 11 cash
      And it should be my Buy phase

  Scenario: Fool's Gold doesn't persist across turns
    Given my hand contains Fool's Gold x2, Copper
      And my deck contains Fool's Gold x5
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Fool's Gold as treasure
      Then I should have 1 cash
      And I should need to Play Treasure
    When I play Fool's Gold as treasure
      Then I should have 5 cash
      And I should need to play treasure
    When my next turn starts
    And I stop playing actions
    And the game checks actions
      Then I should have 0 cash
      And I should need to Play Treasure
    When I play Fool's Gold as treasure
      Then I should have 1 cash
      And I should need to Play Treasure
    When I play Fool's Gold as treasure
      Then I should have 5 cash
      And I should need to play treasure

  Scenario: Using ability on Province gain (autofools-gold ask)
    Given my hand contains Fool's Gold x2
      And Bob's hand contains Gold x3
      And I have setting autofoolsgold set to ASK
      And it is Bob's Play Action phase
    When Bob stops playing actions
    And the game checks actions
      Then Bob should have played Gold x3 as treasure
    When Bob buys Province
    And the game checks actions
      Then Bob should have gained Province
      And I should need to Decide whether to exchange Fool's Gold for Gold
    When I choose the option Trash
      Then I should have removed Fool's Gold from my hand
    When the game checks actions
      Then I should have gained Gold
      And I should need to Decide whether to exchange Fool's Gold for Gold
    When I choose the option Don't trash
      Then nothing should have happened

  Scenario: Acting on Province gain (autofools-gold always)
    Given my hand contains Fool's Gold x2
      And Bob's hand contains Bridge, Gold x3
      And I have setting autofoolsgold set to ALWAYS
      And it is Bob's Play Action phase
    When Bob plays Bridge
    And the game checks actions
      Then Bob should have played Gold x3 as treasure
    When Bob buys Province
    And the game checks actions
      Then the following 3 steps should happen at once
        Then Bob should have gained Province
        And I should have removed Fool's Gold x2 from my hand
        And I should have gained Gold x2
      And it should be Bob's Buy phase

  Scenario: Acting on Province gain (autofools-gold never)
    Given my hand contains Fool's Gold x2
      And Bob's hand contains Bridge, Gold x3
      And I have setting autofoolsgold set to NEVER
      And it is Bob's Play Action phase
    When Bob plays Bridge
    And the game checks actions
      Then Bob should have played Gold x3 as treasure
    When Bob buys Province
    And the game checks actions
      Then Bob should have gained Province
      And I should not need to act
      And it should be Bob's Buy phase

  Scenario: Doesn't trigger on my Province gain
    Given my hand contains Fool's Gold, Gold, Remodel
      And I have setting autofoolsgold set to ASK
      And it is my Play Action phase
    When I play Remodel
    And I choose Gold in my hand
      Then I should have removed Gold from my hand
    When I choose the Province pile
    And the game checks actions
      Then I should have gained Province
      And it should be my Play Treasure phase

  Scenario: Doesn't trigger if Fool's Gold isn't in hand
    Given my hand contains Copper
      And my deck contains Fool's Gold
      And I have Fool's Gold in discard
      And Bob's hand contains Bridge, Gold x3
      And I have setting autofoolsgold set to ASK
      And it is Bob's Play Action phase
    When Bob plays Bridge
    And the game checks actions
      Then Bob should have played Gold x3 as treasure
    When Bob buys Province
    And the game checks actions
      Then Bob should have gained Province
      And I should not need to act
      And it should be Bob's Buy phase