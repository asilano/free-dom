Feature: Saboteur
  Attack - Each other player reveals cards from the top of his deck until he reveals one costing 3 or more. 
            He trashes that card and may gain a card costing at most 2 less than it. He discards the other revealed cards.
            
  Background:
    Given I am a player in a standard game with Saboteur, Pawn, Smithy, Mine, Adventurer

  Scenario: Saboteur should be set up at game start
    Then there should be 10 Saboteur cards in piles
      And there should be 0 Saboteur cards not in piles
      
  Scenario: Playing Saboteur
    Given my hand contains Saboteur, Duchy x4
      And Bob's deck contains Silver, Copper x4
      And Charlie's deck contains Curse, Copper, Pawn, Platinum
    When I play Saboteur
      And the game checks actions
    Then the following 3 steps should happen at once
      Then Bob should have removed Silver from his deck
      And Charlie should have moved Curse, Copper, Pawn from deck to discard
      And Charlie should have removed Platinum from his deck
    And Bob should need to Take a replacement card
      And Charlie should need to Take a replacement card
      And Bob should be able to choose the Copper, Curse piles
        And Bob should not be able to choose the Pawn, Silver, Smithy, Mine, Adventurer piles
      And Charlie should be able to choose the Copper, Pawn, Silver, Smithy, Mine, Adventurer piles
        And Charlie should not be able to choose the Province pile
    When Bob chooses Take nothing for piles
    Then nothing should have happened
    When Charlie chooses the Mine pile
      And the game checks actions
    Then Charlie should have gained Mine
      And it should be my Buy phase
    
  Scenario: Playing Saboteur and missing
    Given my hand contains Saboteur, Duchy x4
      And Bob's deck is empty
      And Charlie's deck contains Curse, Copper, Pawn, Moat
    When I play Saboteur
      And the game checks actions
    Then Charlie should have moved Curse, Copper, Pawn, Moat from deck to discard
      And it should be my Buy phase
      
  Scenario: Saboteur requires a shuffle
    Given my hand contains Saboteur, Duchy x4
      And Bob's deck is empty
      And Charlie's deck contains Curse, Copper
      And Charlie has Pawn, Moat, Platinum, Smithy in discard
    When I play Saboteur
      And the game checks actions
    Then the following 3 steps should happen at once
      Then Charlie should have shuffled his discards
      And Charlie should have moved Curse, Copper, Moat, Pawn from deck to discard
      And Charlie should have removed Platinum from his deck
    And Charlie should need to Take a replacement card
      And Charlie should be able to choose the Copper, Pawn, Silver, Smithy, Mine, Adventurer piles
        And Charlie should not be able to choose the Province pile    
    When Charlie chooses the Mine pile
      And the game checks actions
    Then Charlie should have gained Mine
      And it should be my Buy phase