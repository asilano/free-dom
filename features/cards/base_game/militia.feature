Feature: Militia
  Attack - +2 Cash. Each other player discards down to 3 cards.
    
  Background:
    Given I am a player in a 4-player standard game with Militia
  
  Scenario: Militia should be set up at game start
    Then there should be 10 Militia cards in piles
      And there should be 0 Militia cards not in piles

  Scenario: Playing Militia
    Given my hand contains Militia
      And Bob's hand contains Copper x5
      And Charlie's hand contains Gold, Village, Curse, Copper  
      And Dave's hand contains Mine
      And it is my Play Action phase
    When I play Militia    
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
        
  Scenario: Playing Militia - Prevented by (Moat/Lighthouse)
    Given my hand contains Militia
      And Bob's hand contains Copper x4, Moat
      And Charlie's hand contains Gold, Village, Curse, Copper
      And Charlie has Lighthouse as a duration
      And Dave's hand contains Mine      
      And Bob has setting automoat on      
      And it is my Play Action phase
    When I play Militia
    Then I should have 2 cash
    When the game checks actions
    Then Bob should not need to act
      And Charlie should not need to act
      And Dave should not need to act
      
      # Buy, not Play Treasure, because nothing blocked the advancement when we checked actions
      And it should be my Buy phase