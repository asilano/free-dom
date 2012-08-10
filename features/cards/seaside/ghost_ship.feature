Feature: Ghost Ship
  Attack - Draw 2 cards. Each other player with 4 or more cards in hand puts cards from his hand on top of his deck until he has 3 cards in his hand.
    
  Background:
    Given I am a player in a 4-player standard game with Ghost Ship
  
  Scenario: Ghost Ship should be set up at game start
    Then there should be 10 Ghost Ship cards in piles
      And there should be 0 Ghost Ship cards not in piles

  Scenario: Playing Ghost Ship
    Given my hand contains Ghost Ship
      And Bob's hand contains Copper x5
      And Charlie's hand contains Gold, Village, Curse, Copper  
      And Dave's hand contains Mine
      And it is my Play Action phase
    When I play Ghost Ship    
    Then I should have drawn 2 cards
    When the game checks actions
    Then Bob should need to Place 2 cards on top of deck
      And Charlie should need to Place 1 card on top of deck
      And Dave should not need to act
      And I should not need to act
    When Bob chooses Copper in his hand
    Then Bob should have moved Copper from his hand to his deck
      And Bob should need to Place 1 card on top of deck
    When Bob chooses Copper in his hand
    Then Bob should have moved Copper from his hand to his deck
    When Charlie chooses Curse in his hand
    Then Charlie should have moved Curse from his hand to his deck
      And it should be my Play Treasure phase
        
  Scenario: Playing Ghost Ship - Prevented by (Moat/Lighthouse)
    Given my hand contains Ghost Ship
      And my deck contains Duchy x5
      And Bob's hand contains Copper x4, Moat
      And Charlie's hand contains Gold, Village, Curse, Copper
      And Charlie has Lighthouse as a duration
      And Dave's hand contains Mine      
      And Bob has setting automoat on      
      And it is my Play Action phase
    When I play Ghost Ship
    Then I should have drawn 2 cards
    When the game checks actions
    Then Bob should not need to act
      And Charlie should not need to act
      And Dave should not need to act
      
      # Buy, not Play Treasure, because nothing blocked the advancement when we checked actions
      And it should be my Buy phase