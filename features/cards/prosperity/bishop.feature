Feature: Bishop
  +1 Cash, +1 VP. Trash a card from your hand. +VP equal to half its cost in coins, rounded down. 
    Each other player may trash a card from his hand.
  
  Background:
    Given I am a player in a standard game with Bishop
    
  Scenario: Bishop should be set up at game start
    Then there should be 10 Bishop cards in piles
      And there should be 0 Bishop cards not in piles
      
  Scenario: Playing Bishop - choose valuable card
    Given my hand contains Bishop, Silver, Copper and 2 other cards
      And Bob's hand contains Copper, Curse
      And Charlie's hand contains Gold
    When I play Bishop
    Then I should have 1 cash
      And my score should be 1
      And I should need to Trash a card for VPs with Bishop
      And Bob should need to Trash a card with Alan's Bishop
      And Charlie should need to Trash a card with Alan's Bishop
    When I choose Silver in my hand
    Then I should have removed Silver from my hand
      And my score should be 2
    When Bob chooses Curse in his hand
    Then Bob should have removed Curse from his hand
    When Charlie chooses Trash nothing in his hand
    Then it should be my Play Treasure phase
      
  Scenario: Playing Bishop - choose valueless card
    Given my hand contains Bishop, Silver, Copper and 2 other cards
      And Bob's hand contains Copper, Curse
      And Charlie's hand contains Gold
    When I play Bishop
    Then I should have 1 cash
      And my score should be 1
      And I should need to Trash a card for VPs with Bishop
      And Bob should need to Trash a card with Alan's Bishop
      And Charlie should need to Trash a card with Alan's Bishop
    When Bob chooses Curse in his hand
    Then Bob should have removed Curse from his hand
    When Charlie chooses Trash nothing in his hand
    Then nothing should have happened
    When I choose Copper in my hand
    Then I should have removed Copper from my hand
      And my score should be 1    
      And it should be my Play Treasure phase
      
  Scenario: Playing Bishop - only one choice    
    Given my hand contains Bishop, Gold x2
      And Bob's hand contains Copper, Curse
      And Charlie's hand contains Gold
    When I play Bishop
    Then I should have removed Gold from my hand
      And I should have 1 cash
      And my score should be 4
      And Bob should need to Trash a card with Alan's Bishop
      And Charlie should need to Trash a card with Alan's Bishop    
    When Bob chooses Curse in his hand
    Then Bob should have removed Curse from his hand
    When Charlie chooses Trash nothing in his hand
    Then it should be my Play Treasure phase
      
  Scenario: Playing Bishop - no choices
    Given my hand contains Bishop
      And Bob's hand is empty
      And Charlie's hand is empty
    When I play Bishop
    Then I should have 1 cash
      And my score should be 1
      And it should be my Play Treasure phase
      