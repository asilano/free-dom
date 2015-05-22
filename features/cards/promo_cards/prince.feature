Feature: Prince
  You may set this aside. If you do, set aside an Action card from your hand costing up to 4. At the start of each of your turns, play that Action, setting it aside again when you discard it from play. (Stop playing it if you fail to set it aside on a turn you play it.)

  Background:
    Given I am a player in a standard game with Prince

  Scenario: Prince should be set up at game start
    Then there should be 10 Prince cards in piles
      And there should be 0 Prince cards not in piles
      And the Prince pile should cost 8

  Scenario: Prince should repeatedly play a normal action
    Given my hand contains Prince, Village, Smithy, Estate x2
      And my deck contains Woodcutter x5, Gold x6
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Village, Smithy in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Village in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Village from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have Village in play
        And I should have drawn a card
      And I should have 3 actions available
      And it should be my Play Action phase
    When I play Woodcutter
    And my turn is about to end
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Village from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
      And it should be Bob's Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have Village in play
        And I should have drawn a card
      And I should have 3 actions available
      And it should be my Play Action phase

  Scenario: Prince should repeatedly play a different normal action
    Given my hand contains Prince, Village, Smithy, Estate x2
      And my deck contains Woodcutter x5, Gold x6
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Village, Smithy in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Smithy in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Smithy from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have Smithy in play
        And I should have drawn 3 cards
      And I should have 1 action available
      And it should be my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have moved Gold x3 from hand to play
    When my turn is about to end
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Smithy from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
      And it should be Bob's Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have Smithy in play
        And I should have drawn 3 cards
      And I should have 1 action available
      And it should be my Play Action phase

  Scenario: Playing Prince with exactly one valid choice
    Given my hand contains Prince, Mine, Smithy, Estate x2
      And my deck contains Woodcutter x5, Gold x6
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Smithy in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Smithy in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Smithy from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have Smithy in play
        And I should have drawn 3 cards
      And I should have 1 action available
      And it should be my Play Action phase

  Scenario: Playing Prince with valid choices, and choosing none
    Given my hand contains Prince, Great Hall, Smithy, Estate x2
      And my deck contains Woodcutter x5, Gold x6
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Great Hall, Smithy in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Leave Prince in play in my hand
      Then it should be my Play Treasure phase
      And I should have Prince in play
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then it should be my Play Action phase

  Scenario: Playing Prince with no valid choices, and choosing to leave in play
    Given my hand contains Prince, Mine, Loan, Estate x2
      And my deck contains Woodcutter x5, Gold x6
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should not be able to choose Mine, Loan, Estate in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Leave Prince in play in my hand
      Then it should be my Play Treasure phase
      And I should have Prince in play
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then it should be my Play Action phase

  Scenario: Playing Prince with no valid choices, and choosing to set aside
    Given my hand contains Prince, Mine, Loan, Estate x2
      And my deck contains Woodcutter x5, Gold x6
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should not be able to choose Mine, Loan, Estate in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Set Prince aside alone in my hand
      Then it should be my Play Treasure phase
      And I should have Prince in play
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then it should be my Play Action phase

  Scenario: Prince can pick expensive cards with cost reducers
    Given my hand contains Prince, Highway, Village, Mine, Nobles
      And my deck contains Estate, Copper, Silver, Duchy x3, Copper x5
      And it is my Play Action phase
    When I play Highway
      Then I should have drawn a card
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Village, Mine in my hand
      And I should not be able to choose Nobles in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Mine in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Mine from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then I should have Mine in play
      And I should need to Trash a card with Mine
    When I choose Silver in my hand
      Then I should have removed Silver from hand
      And I should need to Take a replacement card with Mine
    When I choose the Gold pile
    And the game checks actions
      Then I should have placed Gold in my hand
      And I should have 1 action available
      And it should be my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have moved Copper, Gold from hand to play
    When my turn is about to end
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Mine from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
      And it should be Bob's Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have Mine in play
        And I should have removed Copper from my hand
      And I should need to Take a replacement card with Mine

  Scenario: Prince works badly with Durations
    Given my hand contains Prince, Village, Caravan, Estate x2
      And my deck contains Woodcutter x5, Gold x6
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Village, Caravan in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Caravan in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Caravan from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have Caravan in enduring
        And I should have drawn 1 cards
      And I should have 2 actions available
      And it should be my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have moved Gold from hand to play
    When my turn is about to end
    And the game checks actions
      Then the following 3 steps should happen at once
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
      And it should be Bob's Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Caravan from enduring to play
        And I should have drawn 1 cards
      And I should have 1 action available
      And it should be my Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then I should have 1 action available
      And it should be my Play Action phase
      And I should have nothing in play

  Scenario: Prince works badly with self-trashers
    Given my hand contains Prince, Village, Feast, Estate x2
      And my deck contains Woodcutter x4, Gold x6
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Village, Feast in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Feast in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Feast from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then I should need to Take a card with Feast
    When I choose the Duchy pile
    And the game checks actions
      Then I should have gained Duchy
      And I should have 1 action available
      And it should be my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should have moved Gold from hand to play
    When my next turn is about to start
    And the game checks actions
      Then I should have 1 action available
      And it should be my Play Action phase

  Scenario: Multiple Princes with good cards
    Given my hand contains Village, Prince x2, Great Hall, Woodcutter
      And my deck contains Estate, Prince, Woodcutter x4, Bridge, Gold x6
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Great Hall, Woodcutter in my hand
    When I choose Great Hall in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Great Hall from my hand
        And I should have removed Prince from play
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Woodcutter in my hand
    When I choose Woodcutter in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Woodcutter from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then I should need to Choose the first card to play at start of turn
      And I should have seen Great Hall, Woodcutter
    When I choose my peeked Woodcutter
      Then I should have Woodcutter in play
      And I should have 2 cash
      And I should have 2 buys available
    When the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Great Hall in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Bridge in my hand
    When I choose Bridge in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Bridge from my hand
        And I should have removed Prince from play
      And it should be my Play Action phase
    When my turn is about to end
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Great Hall, Woodcutter from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
      And it should be Bob's Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then I should need to Choose the first card to play at start of turn
      And I should have seen Great Hall, Woodcutter, Bridge
    When I choose my peeked Great Hall
      Then the following 2 steps should happen at once
        Then I should have Great Hall in play
        And I should have drawn a card
      And I should have 2 actions available
    When the game checks actions
      Then I should need to Choose the next card to play at start of turn
      And I should have seen Woodcutter, Bridge
    When I choose my peeked Bridge
      Then I should have placed Bridge in play
      And I should have 1 cash
      And the Silver pile should cost 2
      And I should have 2 buys available
    When the game checks actions
      Then I should have placed Woodcutter in play
      And I should have 3 cash
      And I should have 3 buys available
      And it should be my Play Action phase

  Scenario: Prince and Durations ending
    Given my hand contains Estate x2, Prince, Caravan, Woodcutter
      And my deck contains Estate, Lighthouse, Woodcutter x4, Wharf, Estate x6
      And it is my Play Action phase
    When I play Caravan
      Then I should have drawn a card
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Woodcutter in my hand
    When I choose Woodcutter in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Woodcutter from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then I should need to Choose the first card to play at start of turn
      And I should have seen Caravan, Woodcutter
    When I choose my peeked Woodcutter
      Then I should have Woodcutter in play
      And I should have 2 cash
      And I should have 2 buys available
    When the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Caravan from enduring to play
        And I should have drawn a card
      And I should have 1 action available
      And it should be my Play Action phase
    When I play Lighthouse
    And I play Wharf
      Then I should have drawn 2 cards
      And it should be my Play Treasure phase
    When the game checks actions
    And my turn is about to end
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Woodcutter from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
      And it should be Bob's Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then I should need to Choose the first card to play at start of turn
      And I should have seen Lighthouse, Wharf, Woodcutter
    When I choose my peeked Wharf
      Then the following 2 steps should happen at once
        Then I should have moved Wharf from enduring to play
        And I should have drawn 2 cards
      And I should have 2 buys available
    When the game checks actions
      Then I should need to Choose the next card to play at start of turn
      And I should have seen Lighthouse, Woodcutter
    When I choose my peeked Woodcutter
      Then I should have placed Woodcutter in play
      And I should have 2 cash
      And I should have 3 buys available
    When the game checks actions
      Then I should have moved Lighthouse from enduring to play
      And I should have 3 cash
      And I should have 1 action available
      And it should be my Play Action phase

  Scenario: Prince with good card continues after Prince with bad card stops
    Given my hand contains Village, Prince x2, Great Hall, Feast
      And my deck contains Estate, Prince, Feast x4, Bridge, Gold x6
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Great Hall, Feast in my hand
    When I choose Great Hall in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Great Hall from my hand
        And I should have removed Prince from play
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Feast in my hand
    When I choose Feast in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Feast from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then I should need to Choose the first card to play at start of turn
      And I should have seen Great Hall, Feast
    When I choose my peeked Feast
      Then I should need to Take a card with Feast
    When I choose the Duchy pile
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have gained Duchy
        And I should have placed Great Hall in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase
    When my turn is about to end
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Great Hall from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
      And it should be Bob's Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Great Hall in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase

  Scenario: Multiple players have Princes#
    Given my hand contains Prince, Village, Smithy, Estate x2
      And my deck contains Woodcutter x5, Gold x6
      And Bob's hand contains Prince, Great Hall, Lookout, Estate x2
      And Bob's deck contains Estate x5, Copper, Gold, Duchy x6
      And Charlie's hand contains Prince, Moat, Estate x3
      And Charlie's deck contains Estate x5, Duchy x2, Province x3
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Village, Smithy in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Village in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Village from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And Bob's next turn starts
    And Bob plays Prince
      Then Bob should need to Choose a card to set aside with Prince
      And Bob should be able to choose Great Hall, Lookout in his hand
    When Bob chooses Lookout in his hand
      Then the following 2 steps should happen at once
        Then Bob should have removed Lookout from his hand
        And Bob should have removed Prince from play
      And it should be Bob's Play Treasure phase
    When the game checks actions
    And Charlie's next turn starts
    And Charlie plays Prince
      Then Charlie should need to Choose a card to set aside with Prince
      And Charlie should be able to choose Moat in his hand
    When Charlie chooses Moat in his hand
      Then the following 2 steps should happen at once
        Then Charlie should have removed Moat from his hand
        And Charlie should have removed Prince from play
      And it should be Charlie's Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Village in play
        And I should have drawn a card
      And I should have 3 actions available
      And it should be my Play Action phase
    When my turn is about to end
    And the game checks actions
      Then the following 5 steps should happen at once
        Then I should have removed Village from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
        And Bob should have placed Lookout in play
      And Bob should have seen Copper, Gold, Duchy
      And Bob should need to Decide where to place each card, with Lookout
    When Bob chooses the matrix Trash the Copper, Deck the Gold, Discard the Duchy
      Then the following 2 steps should happen at once
        Then Bob should have removed Copper from his deck
        And Bob should have moved card 2 from deck to discard
      And Bob should have 2 actions available
      And it should be Bob's Play Action phase
    When Bob's turn is about to end
    And the game checks actions
      Then the following 6 steps should happen at once
        Then Bob should have removed Lookout from play
        And Bob should have discarded his hand
        And Bob should have discarded his in-play cards
        And Bob should have drawn 5 cards
        And Charlie should have placed Moat in play
        And Charlie should have drawn 2 cards
      And Charlie should have 1 action available
      And it should be Charlie's Play Action phase
    When Charlie's turn is about to end
    And the game checks actions
      Then the following 6 steps should happen at once
        Then Charlie should have removed Moat from play
        And Charlie should have discarded his hand
        And Charlie should have discarded his in-play cards
        And Charlie should have drawn 5 cards
        And I should have placed Village in play
        And I should have drawn a card
      And I should have 3 actions available
      And it should be my Play Action phase
    When my turn is about to end
    And the game checks actions
      Then the following 6 steps should happen at once
        Then I should have removed Village from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
        And Bob should have placed Lookout in play
        And Bob should have shuffled his discards
      And Bob should have seen Duchy x2, Estate
      And Bob should need to Decide where to place each card, with Lookout
    When Bob chooses the matrix Trash the Estate, Deck the Duchy, Discard the Duchy
      Then the following 2 steps should happen at once
        Then Bob should have removed Estate from his deck
        And Bob should have moved Duchy from deck to discard
      And Bob should have 2 actions available
      And it should be Bob's Play Action phase
    When Bob's turn is about to end
    And the game checks actions
      Then the following 6 steps should happen at once
        Then Bob should have removed Lookout from play
        And Bob should have discarded his hand
        And Bob should have discarded his in-play cards
        And Bob should have drawn 5 cards
        And Charlie should have placed Moat in play
        And Charlie should have drawn 2 cards
      And Charlie should have 1 action available
      And it should be Charlie's Play Action phase

  Scenario: Princed Prince triggers once, then the second one repeatedly
    Given my hand contains Prince x2, Highway x4
      And my deck contains Estate x4, Great Hall, Duchy x4, Province x6
      And it is my Play Action phase
    When I play Highway
      Then I should have drawn a card
    When I play Highway
      Then I should have drawn a card
    When I play Highway
      Then I should have drawn a card
    When I play Highway
      Then I should have drawn a card
    When I play Prince
    And I choose Prince in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Prince from play
        And I should have removed Prince from my hand
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then I should have placed Prince in play
      And I should need to Choose a card to set aside with Prince
      And I should be able to choose Great Hall in my hand
    When I choose Great Hall in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Great Hall from my hand
        And I should have removed Prince from play
      And it should be my Play Action phase
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Great Hall in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase
    When my turn is about to end
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Great Hall from play
        And I should have discarded my hand
        And I should have discarded my in-play cards
        And I should have drawn 5 cards
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Great Hall in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase
