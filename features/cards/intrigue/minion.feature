Feature: Minion
  Attack - +1 Action. Choose one: +2 cash; 
           or discard your hand and draw 4 cards, and each other player with 5 or more cards in hand discards his hand and draws 4.
           
  Background:
    Given I am a player in a standard game with Minion
  
  Scenario: Minion should be set up at game start
    Then there should be 10 Minion cards in piles
      And there should be 0 Minion cards not in piles
      
  Scenario: Playing nice Minion
    Given my hand contains Minion and 4 other cards
      And it is my Play Action phase
    When I play Minion
    Then I should have 1 action available
      And I should need to Choose Minion mode
    When I choose the option +2 Cash
    Then I should have 2 cash
    When the game checks actions
    Then it should be my Play Action phase
      
  Scenario: Playing nasty Minion
    Given my hand contains Minion and 2 other cards named "rest of hand"
      And my deck contains Gold x5
      And Bob's hand contains 4 cards
      And Charlie's hand contains 5 cards named "Charlie's hand"
    When I play Minion
    Then I should have 1 action available
      And I should need to Choose Minion mode
    When I choose the option Cycle hands
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have discarded the cards named "rest of hand"
      And I should have drawn 4 cards
      And Charlie should have discarded the cards named "Charlie's hand"
      And Charlie should have drawn 4 cards
    And it should be my Play Action phase 
