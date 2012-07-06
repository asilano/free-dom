Feature: Goons
  Attack - +1 Buy, +2 Cash. Each other player discards down to 3 cards.
      While this is in play, when you buy a card, +1 VP
    
  Background:
    Given I am a player in a 4-player standard game with Goons, Pawn
  
  Scenario: Goons should be set up at game start
    Then there should be 10 Goons cards in piles
      And there should be 0 Goons cards not in piles

  Scenario: Playing Goons
    Given my hand contains Goons, Silver
      And Bob's hand contains Copper x5
      And Charlie's hand contains Gold, Village, Curse, Copper  
      And Dave's hand contains Mine
      And it is my Play Action phase
    When I play Goons
    Then I should have 2 cash
    When the game checks actions
    Then Bob should need to Discard 2 cards
      And Charlie should need to Discard 1 card
      And Dave should not need to act
      And I should not need to act
    When Bob chooses Copper in his hand
    Then Bob should have discarded Copper
      And Bob should need to Discard 1 card
    When Bob chooses Copper in his hand
    Then Bob should have discarded Copper
    When Charlie chooses Curse in his hand
    Then Charlie should have discarded Curse
      And it should be my Play Treasure phase
      And I should have 2 buys available
    When the game checks actions
    Then I should have played Silver 
      And it should be my Buy phase
      And I should have 4 cash
    When I buy Pawn
    Then my score should be 1
    When the game checks actions
    Then I should have gained Pawn
      And it should be my Buy phase
    When I buy Pawn
    Then my score should be 2
    When the game checks actions
    Then the following 3 steps should happen at once 
      Then I should have gained Pawn
      And I should have moved Goons, Silver from play to discard
      And I should have drawn 5 cards
    And it should be Bob's Play Action phase
        
  Scenario: Playing Goons - attack prevented by (Moat/Lighthouse)
    Given my hand contains Goons
      And Bob's hand contains Copper x4, Moat
      And Charlie's hand contains Gold, Village, Curse, Copper
      And Charlie has Lighthouse as a duration
      And Dave's hand contains Mine      
      And Bob has setting automoat on      
      And it is my Play Action phase
    When I play Goons
    Then I should have 2 cash
    When the game checks actions
    Then Bob should not need to act
      And Charlie should not need to act
      And Dave should not need to act
      And it should be my Buy phase