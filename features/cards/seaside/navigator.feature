Feature: Navigator
  2 Cash.
  Look at the top 5 cards of your deck. Either discard all of them, or put them back on top of your deck in any order.

  Background:
    Given I am a player in a standard game with Navigator

  Scenario: Navigator should be set up at game start
    Then there should be 10 Navigator cards in piles
      And there should be 0 Navigator cards not in piles

  Scenario: Playing Navigator - discard
    Given my hand contains Navigator and 4 other cards
      And my deck contains Province x2, Duchy x3, Gold x4
      And it is my Play Action phase
    When I play Navigator
      Then I should have seen Province x2, Duchy x3
      And I should need to Choose whether to discard the seen cards with Navigator
    When I choose the option Discard seen cards
      Then I should have moved Province x2, Duchy x3 from deck to discard
      And I should have 2 cash available
      And it should be my Play Treasure phase

  Scenario: Playing Navigator - return same order
    Given my hand contains Navigator, Village x2, Copper x2
      And my deck contains Province x2, Duchy x3, Gold x4
      And it is my Play Action phase
    When I play Navigator
      Then I should have seen Province x2, Duchy x3
      And I should need to Choose whether to discard the seen cards with Navigator
    When I choose the option Don't discard (keep order)
      Then nothing should have happened
      And I should have 2 cash available
      And it should be my Play Treasure phase
      # No need to verify order hasn't changed explicitly as test harness does that

  Scenario: Playing Navigator - return, choose order
    Given my hand contains Navigator, Village, Library
      And my deck contains Adventurer, Bazaar, Chancellor, Duchy, Embargo, Gold x4
      And it is my Play Action phase
    When I play Navigator
      Then I should have seen Adventurer, Bazaar, Chancellor, Duchy, Embargo
      And I should need to Choose whether to discard the seen cards with Navigator
    When I choose the option Don't discard (choose order)
      Then I should need to Put a card 5th from top with Navigator
    # Choose cards in the order D B A E C, i.e. deck will be C E A B D
    When I choose my peeked Duchy
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have removed Duchy from my deck
        And I should have put Duchy on top of my deck
      And I should need to Put a card 4th from top with Navigator
    When I choose my peeked Bazaar
      And the game checks actions
      # because the deck only gets renumbered when actions are checked
      Then the following 2 steps should happen at once
        Then I should have removed Bazaar from my deck
        And I should have put Bazaar on top of my deck
      And I should need to Put a card 3rd from top with Navigator
    When I choose my peeked Adventurer
      And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have removed Adventurer from my deck
        And I should have put Adventurer on top of my deck
      And I should need to Put a card 2nd from top with Navigator
    When I choose my peeked Embargo
      And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have removed Embargo, Chancellor from my deck
        And I should have put Embargo on top of my deck
        And I should have put Chancellor on top of my deck
    # Check deck order, for sanity, as the above steps are pretty opaque
    Then my deck should contain Chancellor, Embargo, Adventurer, Bazaar, Duchy, Gold x4
      And it should be my Buy phase
      And I should have 2 cash available
