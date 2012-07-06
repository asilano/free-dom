Feature: Lighthouse
  +1 Action. Now and at the start of your next turn: +1 Coin. - While this is in play, when another player plays an Attack card, it doesn't affect you.
  
  Background:
    Given I am a player in a standard game with Lighthouse
    
  Scenario: Lighthouse should be set up at game start
    Then there should be 10 Lighthouse cards in piles
      And there should be 0 Lighthouse cards not in piles
      
  Scenario: Playing Lighthouse for cash
    Given my hand contains Lighthouse and 4 other cards
      And it is my Play Action phase
    When I play Lighthouse
    Then I should have 1 cash
      And I should have 1 action available
    When my next turn starts
    Then I should have 1 cash
      And I should have moved Lighthouse from enduring to play
      And I should have 1 action available
      
  Scenario: Playing Lighthouse for defence
    Given my hand contains Lighthouse and 4 other cards
      And Bob's hand contains Militia, 4x Estate
      And Charlie's hand is empty
      And it is my Play Action phase
    When I play Lighthouse
      Then I should have 1 action available
    When Bob's next turn starts
      And Bob plays Militia
      And the game checks actions
    Then Bob should have 2 cash 
      And I should have 5 cards in hand
      And I should not need to act
      
  Scenario: Lighthouse doesn't protect against your attacks
    Given my hand contains Lighthouse, Spy and 3 other cards
      And my deck contains Copper
      And Bob's deck contains Silver
      And Charlie's deck contains Gold
      And it is my Play Action phase
    When I play Lighthouse
      And the game checks actions
    And I play Spy
      And the game checks actions
    Then I should have drawn 1 card
      And I should need to Choose Spy actions for Alan
      And I should need to Choose Spy actions for Bob
      And I should need to Choose Spy actions for Charlie 