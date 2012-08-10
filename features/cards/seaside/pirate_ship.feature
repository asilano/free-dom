Feature: Pirate Ship
  Attack - Choose one: Each other player reveals the top 2 cards of his deck, trashes a revealed Treasure that you choose, discards the rest, and if anyone trashed a Treasure you take a Coin token; or, +1 cash per Coin token you've taken with Pirate Ships this game.

  Background:
    Given I am a player in a standard game with Pirate Ship

  Scenario: Pirate Ship should be set up at game start
    Then there should be 10 Pirate Ship cards in piles
      And there should be 0 Pirate Ship cards not in piles
      
  Scenario Outline: Playing Pirate Ship for cash
    Given my hand contains Lighthouse, Pirate Ship, Estate x3
      And my state pirate_coins is <coins>
    When I play Lighthouse
      Then I should have 1 cash available
      And I should have 1 action available
    When I play Pirate Ship
      Then I should need to Choose Pirate Ship mode
    When I choose the option Gain cash
      Then I should have <coins_plus_one> cash available
    When the game checks actions
      Then it should be my Buy phase
      
    Examples:
      | coins | coins_plus_one |
      |   0   |       1        |
      |   1   |       2        |
      |   4   |       5        |
      |   10  |       11       | 

  Scenario: Playing Pirate Ship - steal autotrashes treasures if just one kind
    Given my hand contains Pirate Ship, Estate x4
      And Bob's deck contains Silver x2
      And Charlie's deck contains Harem, Great Hall
    When I play Pirate Ship
      Then I should need to Choose Pirate Ship mode
    When I choose the option Trash treasures
      And the game checks actions
      Then the following 4 steps should happen at once
        Then Bob should have removed Silver from his deck
        And Bob should have moved Silver from deck to discard
        And Charlie should have removed Harem from his deck
        And Charlie should have moved Great Hall from deck to discard
      And my state pirate_coins should be 1
      
  Scenario: Playing Pirate Ship - steal offers choice of treasure if multiple
    Given my hand contains Pirate Ship, Estate x4
      And Bob's deck contains Silver, Gold
      And Charlie's deck contains Harem, Hoard
    When I play Pirate Ship
      Then I should need to Choose Pirate Ship mode
    When I choose the option Trash treasures
      And the game checks actions
      Then Bob should be revealing Silver, Gold
      And Charlie should be revealing Harem, Hoard
      And I should need to Choose Pirate Ship actions for Bob
      And I should need to Choose Pirate Ship actions for Charlie
    When I choose Trash for Bob's revealed Gold
      Then the following 2 steps should happen at once
        Then Bob should have removed Gold from his deck
        And Bob should have moved Silver from deck to discard
    When I choose Trash for Charlie's revealed Hoard
      Then the following 2 steps should happen at once
        Then Charlie should have removed Hoard from his deck
        And Charlie should have moved Harem from deck to discard
    When the game checks actions
      Then my state pirate_coins should be 1
      And it should be my Buy phase
      
  Scenario: Playing multiple Pirate Ships 
    Given my hand contains Village x2, Pirate Ship x3
      And my deck contains Duchy x5
      And Bob's deck contains Silver x2, Curse x2
      And Charlie's deck contains Copper, Estate, Harem, Great Hall
    When I play Village
      Then I should have drawn a card
    When I play Village
      Then I should have drawn a card
    When I play Pirate Ship
      Then I should need to Choose Pirate Ship mode
    When I choose the option Trash treasures
      And the game checks actions
      Then the following 4 steps should happen at once
        Then Bob should have removed Silver from his deck
        And Bob should have moved Silver from deck to discard
        And Charlie should have removed Copper from his deck
        And Charlie should have moved Estate from deck to discard
    When the game checks actions
      Then my state pirate_coins should be 1
      And it should be my Play Action phase
    When I play Pirate Ship
      Then I should need to Choose Pirate Ship mode
    When I choose the option Trash treasures
      And the game checks actions
      Then the following 3 steps should happen at once
        Then Bob should have moved Curse x2 from deck to discard
        And Charlie should have removed Harem from his deck
        And Charlie should have moved Great Hall from deck to discard
    When the game checks actions
      Then my state pirate_coins should be 2
      And it should be my Play Action phase
    When I play Pirate Ship
      Then I should need to Choose Pirate Ship mode
    When I choose the option Gain cash
      Then I should have 2 cash available
    When the game checks actions
      Then it should be my Buy phase

  Scenario: Playing Pirate Ship - Whiff, and no cards
    Given my hand contains Pirate Ship, Bank and 3 other cards # need Bank to halt play
      And Bob's deck contains Smithy, Moat and 3 other cards
      And Charlie's deck is empty
    When I play Pirate Ship
      Then I should need to Choose Pirate Ship mode
    When I choose the option Trash treasures
      And the game checks actions
    Then Bob should have moved Smithy, Moat from deck to discard
    And I should need to Play Treasure
    
  Scenario: Playing Pirate Ship - defendable; still grants coins if hits some players
    Given my hand contains Throne Room, Pirate Ship
      And Bob's deck contains Gold, Silver, Copper
      And Bob has Lighthouse as a duration
      And Charlie's deck contains Province, Estate, Gold, Gold
    When I play Throne Room
      And the game checks actions
      Then I should have moved Pirate Ship from my hand to play 
      And I should need to Choose Pirate Ship mode
    When I choose the option Trash treasures
      And the game checks actions
      Then Charlie should have moved Province, Estate from deck to discard
      And my state pirate_coins should be 0
      And I should need to Choose Pirate Ship mode
    When I choose the option Trash treasures
      And the game checks actions
      Then the following 2 steps should happen at once
        Then Charlie should have removed Gold from his deck
        And Charlie should have moved Gold from deck to discard
      And my state pirate_coins should be 1
      And it should be my Buy phase
