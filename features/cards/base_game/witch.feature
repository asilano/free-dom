Feature: Witch
  Attack - Draw 2 cards. Each other player gains a Curse card.
    
  Background:
    Given I am a player in a standard game with Witch
  
  Scenario: Witch should be set up at game start
    Then there should be 10 Witch cards in piles
      And there should be 0 Witch cards not in piles

  Scenario: Playing Witch
    Given my hand contains Witch
      And my deck contains Market x3
      And it is my Play Action phase
    When I play Witch
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have drawn 2 cards
      And Bob should have gained Curse
      And Charlie should have gained Curse
      And it should be my Buy phase
      
  Scenario: Playing Witch - Prevented by (Moat/Lighthouse)
    Given my hand contains Witch
      And Bob's hand contains Great Hall, Great Hall, Moat
      And Charlie's hand contains Estate, Duchy, Curse
      And Charlie has Lighthouse as a duration
      And Bob has setting automoat on
      And my deck contains Market x3
      And it is my Play Action phase
    When I play Witch
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have drawn 2 cards
      And Bob should not need to act
      And Charlie should not need to act
      And it should be my Buy phase

