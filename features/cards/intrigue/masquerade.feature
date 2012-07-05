Feature: Masquerade
  Draw 2 cards. Each player passes a card from his or her hand to the left at once. 
  Then you may trash a card from your hand. (This is not an Attack)
  
  Background:
    Given I am a player in a standard game with Masquerade
    
  Scenario: Masquerade should be set up at game start
    Then there should be 10 Masquerade cards in piles
      And there should be 0 Masquerade cards not in piles
      
  Scenario: Playing Masquerade
    Given my hand contains Masquerade, Curse and 3 other cards
      And Bob's hand contains Estate and 4 other cards
      And Charlie's hand contains Copper and 4 other cards
      And my deck contains Gold x3
    When I play Masquerade
    Then I should have drawn 2 cards
      And I should need to Pass a card to Bob
      And Bob should need to Pass a card to Charlie
      And Charlie should need to Pass a card to Alan
    When I choose Curse in my hand
    Then I should have removed Curse from my hand
    When the game checks actions
    Then nothing should have happened
    When Bob chooses Estate in his hand
    Then Bob should have removed Estate from his hand
    When the game checks actions
    Then Bob should have placed Curse in his hand
    When Charlie chooses Copper in his hand
    Then Charlie should have removed Copper from his hand
    When the game checks actions
    Then the following 2 steps should happen at once
      Then I should have placed Copper in my hand
      And Charlie should have placed Estate in his hand
    And I should need to Optionally trash a card with Masquerade
    When I choose Copper in my hand
    Then I should have removed Copper from my hand
      And it should be my Play Treasure phase

  Scenario: Playing Masquerade - Opp has no cards
    Given my hand contains Masquerade, Curse and 3 other cards
      And Bob's hand is empty
      And Charlie's hand contains Copper and 4 other cards
      And my deck contains Gold x3
    When I play Masquerade
    Then I should have drawn 2 cards
      And I should need to Pass a card to Bob
      And Bob should need to Pass a card to Charlie
      And Charlie should need to Pass a card to Alan
    When I choose Curse in my hand
    Then I should have removed Curse from my hand
    When the game checks actions
    Then nothing should have happened
    When Charlie chooses Copper in his hand
    Then Charlie should have removed Copper from his hand
    When the game checks actions
    Then I should have placed Copper in my hand    
    When Bob chooses Pass nothing in his hand
    Then nothing should have happened
    When the game checks actions
    Then Bob should have placed Curse in his hand
      And I should need to Optionally trash a card with Masquerade
    When I choose Copper in my hand
    Then I should have removed Copper from my hand
      And it should be my Play Treasure phase
    
  Scenario: Playing Masquerade - I have no cards
    Given my hand contains Masquerade
      And Bob's hand contains Estate and 4 other cards
      And Charlie's hand contains Copper and 4 other cards
      And my deck is empty
    When I play Masquerade
    Then I should need to Pass a card to Bob
      And Bob should need to Pass a card to Charlie
      And Charlie should need to Pass a card to Alan
    When I choose Pass nothing in my hand
      And the game checks actions
    Then nothing should have happened
    When Bob chooses Estate in his hand
    Then Bob should have removed Estate from his hand
    When the game checks actions
    Then nothing should have happened
    When Charlie chooses Copper in his hand
    Then Charlie should have removed Copper from his hand
    When the game checks actions
    Then the following 2 steps should happen at once
      Then I should have placed Copper in my hand
      And Charlie should have placed Estate in his hand
    And I should need to Optionally trash a card with Masquerade
    When I choose Copper in my hand
    Then I should have removed Copper from my hand
      And it should be my Play Treasure phase
    
  Scenario: Playing Masquerade - I and RH Opp have no cards
    Given my hand contains Masquerade
      And Bob's hand contains Estate and 4 other cards
      And Charlie's hand is empty
      And my deck is empty
    When I play Masquerade
    Then I should need to Pass a card to Bob
      And Bob should need to Pass a card to Charlie
      And Charlie should need to Pass a card to Alan
    When I choose Pass nothing in my hand
      And the game checks actions
    Then nothing should have happened
    When Bob chooses Estate in his hand
    Then Bob should have removed Estate from his hand
    When the game checks actions
    Then nothing should have happened
    When Charlie chooses Pass nothing in his hand
    Then nothing should have happened
    When the game checks actions
    Then Charlie should have placed Estate in his hand
      And I should need to Optionally trash a card with Masquerade
    When I choose Trash nothing in my hand
    Then it should be my Play Treasure phase