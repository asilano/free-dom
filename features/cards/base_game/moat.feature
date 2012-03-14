Feature: Moat
  Draw 2 cards
  (Reaction) - When another player plays an Attack card, you may reveal this from your hand. If you do, you are not affected by that attack
  
  Background:
    Given I am a player in a standard game with Moat
  
  Scenario: Moat should be set up at game start
    Then there should be 10 Moat cards in piles
      And there should be 0 Moat cards not in piles
  
  Scenario: Playing Moat draws three cards
    Given my hand contains Moat and 4 other cards
      And my deck contains 5 cards
      And I have nothing in play
      And it is my Play Action phase
    When I play Moat
    Then I should have drawn 2 cards
      And it should be my Play Treasure phase
      
  Scenario: Automoat prevents other attacks
    Given PENDING
    
  Scenario: Automoat off - ask to prevent attack
    Given PENDING
    
  Scenario: Moat doesn't protect against your attacks
    Given PENDING
    