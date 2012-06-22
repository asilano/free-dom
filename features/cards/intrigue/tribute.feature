Feature: Tribute
  The player to your left discards the top 2 cards of his deck. 
    For each differently-named card discarded, if it's an Action, +2 Actions; Treasure, +2 Cash; Victory, draw 2 cards.
            
  Background:
    Given I am a player in a standard game with Tribute

  Scenario: Tribute should be set up at game start
    Then there should be 10 Tribute cards in piles
      And there should be 0 Tribute cards not in piles
      
  Scenario: Playing Tribute - Action, Treasure
    Given my hand contains Tribute and 4 other cards
      And Bob's deck contains Smithy, Copper and 3 other cards
    When I play Tribute
    Then Bob should have moved Smithy, Copper from deck to discard
      And it should be my Play Action phase
      And I should have 2 actions available
      And I should have 2 cash
      
  Scenario: Playing Tribute - Victory, Curse
    Given my hand contains Tribute and 4 other cards
      And Bob's deck contains Estate, Curse and 3 other cards
    When I play Tribute
    Then the following 2 steps should happen at once
      Then Bob should have moved Estate, Curse from deck to discard
      And I should have drawn 2 cards
    And it should be my Play Treasure phase
    
  Scenario: Playing Tribute - two different Victories
    Given my hand contains Tribute and 4 other cards
      And Bob's deck contains Estate, Duchy and 3 other cards
    When I play Tribute
    Then the following 2 steps should happen at once
      Then Bob should have moved Estate, Duchy from deck to discard
      And I should have drawn 4 cards
    And it should be my Play Treasure phase
    
  Scenario: Playing Tribute - subtyped cards are actions
    Given my hand contains Tribute and 4 other cards
      And Bob's deck contains Lighthouse, Moat and 3 other cards
    When I play Tribute
    Then Bob should have moved Lighthouse, Moat from deck to discard      
      And it should be my Play Action phase
      And I should have 4 actions available
      
  Scenario: Playing Tribute - hybrid cards are both types
    Given my hand contains Tribute and 4 other cards
      And Bob's deck contains Nobles, Harem and 3 other cards
    When I play Tribute
    Then the following 2 steps should happen at once
      Then Bob should have moved Nobles, Harem from deck to discard
      And I should have drawn 4 cards
    And it should be my Play Action phase
      And I should have 2 actions available
      And I should have 2 cash
      
  Scenario: Playing Tribute - small deck
    Given my hand contains Tribute and 4 other cards
      And Bob's deck contains Estate
    When I play Tribute
    Then the following 2 steps should happen at once
      Then Bob should have moved Estate from deck to discard
      And I should have drawn 2 cards
    And it should be my Play Treasure phase      