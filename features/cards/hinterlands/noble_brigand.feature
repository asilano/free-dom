Feature: Noble Brigand
  +1 Coin
  When you buy this or play it, each other player reveals the top 2 cards of his deck,
  trashes a revealed Silver or Gold you choose, and discards the rest.
  If he didn't reveal a Treasure, he gains a Copper. You gain the trashed cards.

  Background:
    Given I am a player in a standard game with Noble Brigand

  Scenario: Noble Brigand should be set up at game start
    Then there should be 10 Noble Brigand cards in piles
      And there should be 0 Noble Brigand cards not in piles
      And the Noble Brigand pile should cost 4

  Scenario: Autobrigand off. Play Noble Brigand. Need to choose
    Given my hand contains Noble Brigand, Village
      And I have setting autobrigand off
      And my deck contains Estate
      And Bob's deck contains Silver, Gold
      And Charlie's deck contains Copper
      And it is my Play Action phase
      And I play Village
        Then I should have drawn a card
    When I play Noble Brigand
      Then I should have 1 cash
    When the game checks actions
      Then Charlie should have moved Copper from his deck to discard
      And I should need to Choose a card to steal from Bob
    When I choose Steal for Bob's revealed Silver
    And the game checks actions
      Then the following 4 steps should happen at once
        Then Bob should have removed Silver from his deck
        And Bob should have moved Gold from his deck to discard
        And I should have gained Silver
    And I should need to Play Action

  Scenario: Autobrigand off. Play Noble Brigand. Two identical treasures
    Given my hand contains Noble Brigand, Village
      And I have setting autobrigand off
      And my deck contains Estate
      And Bob's deck contains Gold, Gold
      And Charlie's deck contains Copper
      And it is my Play Action phase
      And I play Village
        Then I should have drawn a card
    When I play Noble Brigand
      Then I should have 1 cash
    When the game checks actions
      Then the following 4 steps should happen at once
        Then Bob should have removed Gold from his deck
        And Bob should have moved Gold from his deck to discard
        And Charlie should have moved Copper from his deck to discard
        And I should have gained Gold
    And I should need to Play Action

  Scenario: Autobrigand off. Play Noble Brigand. Just one Silver
    Given my hand contains Noble Brigand, Village
      And I have setting autobrigand off
      And my deck contains Estate
      And Bob's deck contains Silver, Estate
      And Charlie's deck contains Duchy, Gold
      And it is my Play Action phase
      And I play Village
        Then I should have drawn a card
    When I play Noble Brigand
      Then I should have 1 cash
    When the game checks actions
      Then the following 5 steps should happen at once
        Then Bob should have removed Silver from his deck
        And Bob should have moved Estate from his deck to discard
        And Charlie should have moved Duchy from his deck to discard
        And Charlie should have removed Gold from his deck
        And I should have gained Silver, Gold
    And I should need to Play Action

  Scenario: Only non-Silver, Gold treasures. No Treasures
    Given my hand contains Noble Brigand, Village
      And my deck contains Estate
      And Bob's deck contains Copper, Harem
      And Charlie's deck contains Estate, Smithy
      And it is my Play Action phase
      And I play Village
        Then I should have drawn a card
    When I play Noble Brigand
      Then I should have 1 cash
    When the game checks actions
      Then the following 3 steps should happen at once
        Then Bob should have moved Copper, Harem from his deck to discard
        And Charlie should have moved Estate, Smithy from his deck to discard
        And Charlie should have gained Copper
    And I should need to Play Action

  Scenario: Autobrigand on. Play Noble Brigand. Autochoose Gold
    Given my hand contains Noble Brigand, Village
      And I have setting autobrigand on
      And my deck contains Estate
      And Bob's deck contains Silver, Gold
      And Charlie's deck contains Copper
      And it is my Play Action phase
      And I play Village
        Then I should have drawn a card
    When I play Noble Brigand
      Then I should have 1 cash
    When the game checks actions
      Then the following 4 steps should happen at once
        Then Bob should have moved Silver from his deck to discard
        And Bob should have removed Gold from his deck
        And Charlie should have moved Copper from his deck to discard
        And I should have gained Gold
    And I should need to Play Action

  Scenario: Autobrigand on. Buy Noble Brigand. Autochoose Gold. Grant Copper
    Given my hand contains Woodcutter, Silver
      And I have setting autobrigand on
      And my deck contains Estate
      And Bob's deck contains Silver, Gold
      And Charlie's deck contains Mint, Mine
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Silver
    When I buy Noble Brigand
    And the game checks actions
      Then the following 5 steps should happen at once
        Then Bob should have moved Silver from his deck to discard
        And Bob should have removed Gold from his deck
        And Charlie should have moved Mint, Mine from his deck to discard
        And Charlie should have gained Copper
        And I should have gained Gold, Noble Brigand
    And I should need to Buy

  Scenario: Reactions and Lighthouse apply only to Noble Brigand play
    Given my hand contains Village, Woodcutter, Noble Brigand, Silver
      And I have setting autobrigand on
      And my deck contains Estate
      And Bob's deck contains Silver, Gold, Silver, Gold
      And Charlie's deck contains Mint, Mine, Mint, Mine
      And Bob's hand contains Moat, Secret Chamber
      And Bob has setting automoat on
      And Charlie has Lighthouse as a duration
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Woodcutter
    And I play Noble Brigand
    And the game checks actions
      Then Bob should need to React to Noble Brigand
    When Bob chooses Don't react in his hand
    And the game checks actions
      Then I should have played Silver
    When I buy Noble Brigand
    And the game checks actions
      Then the following 5 steps should happen at once
        Then Bob should have moved Silver from his deck to discard
        And Bob should have removed Gold from his deck
        And Charlie should have moved Mint, Mine from his deck to discard
        And Charlie should have gained Copper
        And I should have gained Gold, Noble Brigand
    And I should need to Buy