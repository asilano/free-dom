Feature: Swindler
  Attack - +2 Cash. Each other player trashes the top card of his or her deck, and gains a card with the same cost of your choice.
            
  Background:
    Given I am a player in a standard game with Swindler, Pawn, Moat, Smithy, Remodel, Mine, Market, Adventurer

  Scenario: Swindler should be set up at game start
    Then there should be 10 Swindler cards in piles
      And there should be 0 Swindler cards not in piles
      
  Scenario: Playing Swindler
    Given my hand contains Swindler, Duchy x4
      And Bob's deck contains Silver
      And Charlie's deck contains Curse
    When I play Swindler
      And the game checks actions
    Then the following 2 steps should happen at once
      Then Bob should have removed Silver from his deck
      And Charlie should have removed Curse from his deck
    And I should need to Choose Swindler actions for Bob
      And I should need to Choose Swindler actions for Charlie
      And I should be able to choose the Silver, Swindler piles labelled Give to Bob
        And I should not be able to choose the Copper, Pawn, Smithy, Mine, Adventurer piles labelled Give to Bob
      And I should be able to choose the Copper, Curse piles labelled Give to Charlie
        And I should not be able to choose the Pawn, Silver, Smithy, Mine, Adventurer piles labelled Give to Charlie     
    When I choose the Silver pile labelled Give to Bob
      And the game checks actions 
    Then Bob should have gained Silver
    When I choose the Curse pile labelled Give to Charlie
      And the game checks actions
    Then Charlie should have gained Curse
      And it should be my Buy phase
      And I should have 2 cash
      
  Scenario: Playing Swindler - check order relevant
    Given PENDING
    
  Scenario: Playing Swindler - empty piles
    Given PENDING