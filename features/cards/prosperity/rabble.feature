Feature: Rabble
  Attack - Draw 3 cards. Each other player reveals the top 3 cards of his deck, 
    discards the revealed Actions and Treasures, and puts the rest back on top in any order.
    
  Background:
    Given I am a player in a standard game with Rabble
  
  Scenario: Rabble should be set up at game start
    Then there should be 10 Rabble cards in piles
      And there should be 0 Rabble cards not in piles

  Scenario: Playing Rabble - hit 3 or 2 cards
    Given my hand contains Rabble
      And my deck contains Market x3
      And Bob's deck contains Smithy, Harem, Moat
      And Charlie's deck contains Copper, Duchy, Nobles
      And it is my Play Action phase
    When I play Rabble
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have drawn 3 cards
      And Bob should have moved cards 0, 1, 2 from deck to discard
      And Charlie should have moved cards 0, 2 from deck to discard
    And it should be my Buy phase
      
  Scenario: Playing Rabble - hit 1 or 0 cards
    Given my hand contains Rabble
      And my deck contains Market x3
      And Bob's deck contains Smithy, Duchy, Estate
      And Charlie's deck contains Curse, Province, Colony
      And it is my Play Action phase
    When I play Rabble
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have drawn 3 cards
      And Bob should have moved Smithy from deck to discard
    And Bob should be revealing Duchy, Estate
      And Charlie should be revealing Curse, Province, Colony
      And Bob should need to Put a card 2nd from top
      And Charlie should need to Put a card 3rd from top
    When Bob chooses his revealed Duchy
    Then Bob should have Estate, Duchy on his deck
      And Bob should not need to act
      And Bob should be revealing nothing
    When Charlie chooses his revealed Province
    Then the following 5 steps should happen at once 
      And Charlie should be revealing Curse, Colony
      And Charlie should need to Put a card 2nd from top
      When Charlie chooses his revealed Colony
      Then Charlie should have Curse, Colony, Province on his deck
      And Charlie should be revealing nothing
    And it should be my Play Treasure phase      
      
  Scenario: Playing Rabble - small decks
    Given my hand contains Rabble
      And my deck contains Market x3
      And Bob's deck contains Smithy
      And Charlie's deck is empty
      And it is my Play Action phase
    When I play Rabble
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have drawn 3 cards
      And Bob should have moved Smithy from deck to discard
    And it should be my Buy phase
      
  Scenario: Playing Rabble - Prevented by (Moat/Lighthouse)
    Given my hand contains Rabble
      And Bob's hand contains Moat
      And Bob's deck contains Smithy, Harem, Watchtower
      And Charlie's deck contains Copper, Duchy, Nobles
      And Charlie has Lighthouse as a duration
      And Bob has setting automoat on
      And my deck contains Market x3
      And it is my Play Action phase
    When I play Rabble
      And the game checks actions
    Then I should have drawn 3 cards      
      And it should be my Buy phase

