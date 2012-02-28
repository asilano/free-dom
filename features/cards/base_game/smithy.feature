Feature: Smithy
  In order for Smithy to be correctly coded
  Playing Smithy
  Should draw three cards
  
  Background:
    Given I am a player in a standard game with Smithy
  
  Scenario: Smithy should be set up at game start
    Then there should be 10 Smithy cards in piles
      And there should be 0 Smithy cards not in piles
  
  Scenario: Playing Smithy draws three cards
    Given my hand contains Smithy and 4 other cards
      And my deck contains 5 cards
      And I have nothing in play
      And it's my Play Action phase
    When I play Smithy
    Then I should have drawn 3 cards
      And it should be my Play Treasure phase
    
  Scenario: Playing Smithy with a small deck draws as much as possible
    Given my hand contains Smithy and 4 other cards
      And my deck contains 2 cards
      And I have nothing in play
      And it's my Play Action phase
      And I have noted the last history
    When I play Smithy
    Then I should have drawn 2 cards
      And later history should include "[I] tried to draw 1 more card, but their deck was empty."
      And it should be my Play Treasure phase
    
  Scenario: Playing Smithy with an empty deck draws nothing
    Given my hand contains Smithy and 4 other cards
      And my deck is empty
      And I have nothing in play
      And it's my Play Action phase
      And I have noted the last history
    When I play Smithy
    Then I should have drawn 0 cards
      And later history should include "[I] drew no cards."
      And later history should include "[I] tried to draw 3 more cards, but their deck was empty."
      And it should be my Play Treasure phase

  Scenario: Playing Smithy with a small deck and discards draws three cards
    Given my hand contains Smithy and 4 other cards
      And my deck contains 2 cards
      And I have nothing in play
      And I have 3 cards in discard
      And it's my Play Action phase
    When I play Smithy
    Then I should have drawn 3 cards
      And it should be my Play Treasure phase