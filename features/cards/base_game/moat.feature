Feature: Moat
  Draw 2 cards
  (Reaction) - When another player plays an Attack card, you may reveal this from your hand. If you do, you are not affected by that attack
  
  Background:
    Given I am a player in a standard game with Moat
  
  Scenario: Moat should be set up at game start
    Then there should be 10 Moat cards in piles
      And there should be 0 Moat cards not in piles
  
  Scenario: Playing Moat draws two cards
    Given my hand contains Moat and 4 other cards
      And my deck contains 5 cards
      And I have nothing in play
      And it is my Play Action phase
    When I play Moat
    Then I should have drawn 2 cards
      And it should be my Play Treasure phase
      
  Scenario: Automoat prevents other attacks
    Given my hand contains Moat, Estate, Duchy and 4 other cards
      And Bob's hand contains Bureaucrat and 4x Market
      And Charlie's hand is empty
      And I have setting automoat on
      And it is Bob's Play Action phase
    When Bob plays Bureaucrat
      And the game checks actions
    Then Bob should have put Silver on top of his deck
      And I should not need to act
      And it should be Bob's Buy phase 
    
  Scenario: Automoat off - ask to prevent attack
    Given my hand contains Moat, Estate, Duchy and 4 other cards
      And Bob's hand contains Bureaucrat and 4x Market
      And Charlie's hand is empty
      And I have setting automoat off
      And it is Bob's Play Action phase
    When Bob plays Bureaucrat
      And the game checks actions
    Then Bob should have put Silver on top of his deck
      And I should need to React to Bureaucrat
    When I choose Moat in my hand
    Then I should need to React to Bureaucrat
    When I choose Don't react in my hand
      And the game checks actions
    Then I should not need to act
      And it should be Bob's Buy phase

  Scenario: Automoat off - choose not to prevent attack
    Given my hand contains Moat, Estate, Duchy and 4 other cards
      And Bob's hand contains Bureaucrat and 4x Market
      And Charlie's hand is empty
      And I have setting automoat off
      And it is Bob's Play Action phase
    When Bob plays Bureaucrat
      And the game checks actions
    Then Bob should have put Silver on top of his deck
      And I should need to React to Bureaucrat
    When I choose Don't react in my hand
      And the game checks actions
    Then I should need to Place a Victory card onto deck

  Scenario: Moat doesn't protect against your attacks
    Given my hand contains Moat, Spy and 3 other cards
      And my deck contains Copper
      And Bob's deck contains Silver
      And Charlie's deck contains Gold
      And it is my Play Action phase
      And I have setting automoat off
    When I play Spy
      And the game checks actions
    Then I should have drawn 1 card
      And I should need to Choose Spy actions for Alan
      And I should need to Choose Spy actions for Bob
      And I should need to Choose Spy actions for Charlie 
