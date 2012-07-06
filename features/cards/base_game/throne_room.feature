Feature: Throne Room
  Choose an action card in your hand. Play it twice.

  Background:
    Given I am a player in a standard game with Throne Room

  Scenario: Throne Room should be set up at game start
    Then there should be 10 Throne Room cards in piles
    And there should be 0 Throne Room cards not in piles

  Scenario: Playing Throne Room - choice of card
    Given my hand contains Throne Room, Village, Smithy and 2 other cards
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play Throne Room
    Then I should need to Choose a card to play with Throne Room
    When I choose Village in my hand
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have played Village
      And I should have drawn 2 cards
    And I should have 4 actions available

  Scenario: Playing Throne Room - only one card
    Given my hand contains Throne Room, Village, Copper x3
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play Throne Room
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have played Village
      And I should have drawn 2 cards
    And I should have 4 actions available

  Scenario: Playing Throne Room - no actions
    Given my hand contains Throne Room, Copper x3
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play Throne Room
    Then it should be my Play Treasure phase

  Scenario: Playing Throne Room - can Throne Room a Throne Room
    Given my hand contains Throne Room x2, Village, Smithy, Copper x2
      And it is my Play Action phase
      And my deck contains Gold x10
    When I play Throne Room
    Then I should need to Choose a card to play with Throne Room
    When I choose Throne Room in my hand
      And the game checks actions
    Then I should have played Throne Room
      And I should need to Choose a card to play with Throne Room
    When I choose Village in my hand
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have played Village
      And I should have drawn 2 cards
      And I should have played Smithy
      And I should have drawn 6 cards
    And I should have 4 actions available
   
  Scenario: Playing Throne Room - doubling a Duration
    Given my hand contains Throne Room, Lighthouse
      And my deck contains Duchy x5
      And Bob's hand is empty
      And Bob's deck is empty
      And Charlie's hand is empty
      And Charlie's deck is empty
      And it is my Play Action phase
    When I play Throne Room
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have played Lighthouse
      And I should have 2 cash
      And I should have moved Throne Room from play to enduring
    And I should have 2 actions available
    When I stop playing actions
      And the game checks actions
      And I stop buying cards
      And the game checks actions
    Then I should have drawn 5 cards    
    When my next turn starts
    Then the following 3 steps should happen at once
      Then I should have 2 cash
      And I should have moved Throne Room, Lighthouse from enduring to play
      And it should be my Play Action phase