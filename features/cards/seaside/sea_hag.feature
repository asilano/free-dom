Feature: Sea Hag
  Attack - Each other player discards the top card of his deck, then gains a Curse card, putting it on top of his deck.
    
  Background:
    Given I am a player in a standard game with Sea Hag
  
  Scenario: Sea Hag should be set up at game start
    Then there should be 10 Sea Hag cards in piles
      And there should be 0 Sea Hag cards not in piles

  Scenario: Playing Sea Hag
    Given my hand contains Sea Hag
      And Bob's deck contains Duchy then 5 other cards
      And Charlie's deck contains Curse
      And it is my Play Action phase
    When I play Sea Hag
      And the game checks actions
      Then the following 4 steps should happen at once
        Then Bob should have moved Duchy from deck to discard
        And Bob should have gained Curse to his deck
        And Charlie should have moved Curse from his deck to his discard
        And Charlie should have gained Curse to his deck
      And it should be my Buy phase
      
  Scenario: Playing Sea Hag - Prevented by (Moat/Lighthouse)
    Given my hand contains Sea Hag
      And Bob's hand contains Great Hall, Great Hall, Moat
      And Charlie's hand contains Estate, Duchy, Curse
      And Charlie has Lighthouse as a duration
      And Bob has setting automoat on
      And it is my Play Action phase
    When I play Sea Hag
      And the game checks actions
    Then nothing should have happened
      And Bob should not need to act
      And Charlie should not need to act
      And it should be my Buy phase

