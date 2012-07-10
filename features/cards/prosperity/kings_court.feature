Feature: King's Court
  You may choose an action card in your hand. Play it three times.

  Background:
    Given I am a player in a standard game with King's Court

  Scenario: King's Court should be set up at game start
    Then there should be 10 King's Court cards in piles
    And there should be 0 King's Court cards not in piles

  Scenario: Playing King's Court - choice of card
    Given my hand contains King's Court, Village, Smithy and 2 other cards
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play King's Court
    Then I should need to Choose a card to play with King's Court
    When I choose Village in my hand
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have played Village
      And I should have drawn 3 cards
    And I should have 6 actions available

  Scenario: Playing King's Court - only one card
    Given my hand contains King's Court, Village, Copper x3
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play King's Court
    Then I should need to Choose a card to play with King's Court
    When I choose Village in my hand
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have played Village
      And I should have drawn 3 cards
    And I should have 6 actions available

  Scenario: Playing King's Court - declining
    Given my hand contains King's Court, Village, Smithy and 2 other cards
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play King's Court
    Then I should need to Choose a card to play with King's Court
    When I choose Choose Nothing in my hand
    Then it should be my Play Treasure phase
  
  Scenario: Playing King's Court - no actions
    Given my hand contains King's Court, Copper x3
      And it is my Play Action phase
      And my deck contains Gold x2 and 3 other cards
    When I play King's Court
    Then it should be my Play Treasure phase

  Scenario: Playing King's Court - can King's Court a King's Court
    Given my hand contains King's Court x2, Village, Smithy, Woodcutter, Copper x2
      And it is my Play Action phase
      And my deck contains Gold x15
    When I play King's Court
    Then I should need to Choose a card to play with King's Court
    When I choose King's Court in my hand
      And the game checks actions
    Then I should have played King's Court
      And I should need to Choose a card to play with King's Court
    When I choose Village in my hand
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have played Village
      And I should have drawn 3 cards
    And I should need to Choose a card to play with King's Court
    When I choose Smithy in my hand
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have played Smithy
      And I should have drawn 9 cards
    And I should need to Choose a card to play with King's Court
    When I choose Woodcutter in my hand
      And the game checks actions
    Then I should have played Woodcutter
      And I should have 6 cash
      And I should have 4 buys available
      And I should have 6 actions available
   
  Scenario: Playing King's Court - tripling a Duration
    Given my hand contains King's Court, Lighthouse
      And my deck contains Duchy x5
      And it is my Play Action phase
    When I play King's Court
    Then I should need to Choose a card to play with King's Court
    When I choose Lighthouse in my hand
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have played Lighthouse
      And I should have 3 cash
      And I should have moved King's Court from play to enduring
    And I should have 3 actions available
    When I stop playing actions
      And the game checks actions
      And I stop buying cards
      And the game checks actions
    Then I should have drawn 5 cards    
    When my next turn starts
    Then the following 3 steps should happen at once
      Then I should have 3 cash
      And I should have moved King's Court, Lighthouse from enduring to play
      And it should be my Play Action phase