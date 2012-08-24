Feature: Cutpurse
  +2 Cash. Each other player discards a Copper card (or reveals a hand with no Copper).
  
  Background:
    Given I am a player in a standard game with Cutpurse
    
  Scenario: Cutpurse should be set up at game start
    Then there should be 10 Cutpurse cards in piles
      And there should be 0 Cutpurse cards not in piles
      
  Scenario: Playing Cutpurse - one opponent with 1 copper, one with none
    Given my hand contains Cutpurse, Estate x4
      And Bob's hand contains Copper, Estate x4
      And Charlie's hand contains Silver, Gold, Platinum
      And it is my Play Action phase
      And I have noted the last history
    When I play Cutpurse
      And the game checks actions
      Then Bob should have discarded Copper
      And later history should include "Charlie revealed Silver, Gold, Platinum."
      And I should have 2 cash
      And it should be my Buy phase

  Scenario: Playing Cutpurse - one opponent with 2 copper, one with 2 and Lighthouse
    Given my hand contains Cutpurse, Estate x4
      And Bob's hand contains Copper x2, Estate x3
      And Charlie's hand contains Copper x2, Estate x3
      And Charlie has Lighthouse as a duration
      And it is my Play Action phase
    When I play Cutpurse
      And the game checks actions
      Then Bob should have discarded Copper
      # And, implicitly, Charlie should not
      And I should have 2 cash
      And it should be my Buy phase
  
  Scenario: Playing multiple Cutpurses
    Given my hand contains Village, Cutpurse x2, Estate x2
      And my deck contains Estate
      And Bob's hand contains Copper x5
      And Charlie's hand contains Copper, Silver, Gold, Platinum
      And it is my Play Action phase
    When I play Village
      Then I should have drawn 1 card
    When I play Cutpurse
      And the game checks actions
    Then the following 2 steps should happen at once
      Then Bob should have discarded Copper
      And Charlie should have discarded Copper
    When I have noted the last history
      And I play Cutpurse
      And the game checks actions
    Then Bob should have discarded Copper
      And later history should include "Charlie revealed Silver, Gold, Platinum."
      And I should have 4 cash
      And it should be my Buy phase