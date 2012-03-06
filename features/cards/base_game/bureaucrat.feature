Feature: Bureaucrat
  Attack - Gain a Silver card; put it on top of your deck.
    Each other player reveals a Victory card from his or her hand and puts it on top of their deck, or reveals a hand with no Victory cards.
    
  Background:
    Given I am a player in a standard game with Bureaucrat
  
  Scenario: Bureaucrat should be set up at game start
    Then there should be 10 Bureaucrat cards in piles
      And there should be 0 Bureaucrat cards not in piles

  Scenario: Playing Bureaucrat - Autocrat off
    Given my hand contains Bureaucrat
      And Bob's hand contains Estate, Copper, Copper
      And Charlie's hand contains Gold, Village, Curse
      And Bob has setting autocrat off
      And Charlie has setting autocrat off
      And my deck contains 3 cards
      And Bob's deck contains 4 cards
      And Charlie's deck is empty
      And it is my Play Action phase
    When I play Bureaucrat
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have put Silver on top of my deck
      And Bob should need to place a Victory card onto deck
      And Charlie should not need to act
    When Bob chooses Estate in his hand
    Then Bob should have put Estate from his hand on top of his deck
      And it should be my Play Treasure phase
      
  Scenario: Playing Bureaucrat - Autocrat on
    Given my hand contains Bureaucrat
      And Bob's hand contains Great Hall, Great Hall, Copper
      And Charlie's hand contains Estate, Duchy, Curse
      And Bob has setting autocrat on
      And Charlie has setting autocrat on
      And my deck contains 3 cards
      And Bob's deck contains 4 cards
      And Charlie's deck is empty
      And it is my Play Action phase
    When I play Bureaucrat
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have put Silver on top of my deck
      And Bob should have put Great Hall from his hand on top of his deck
      And Bob should not need to act
      And Charlie should need to place a Victory card onto deck      
    When Charlie chooses Duchy in his hand
    Then Charlie should have put Duchy from his hand on top of his deck
      And it should be my Play Treasure phase
  
  Scenario: Playing Bureaucrat - Prevented by (Moat/Lighthouse)
    Given my hand contains Bureaucrat
      And Bob's hand contains Great Hall, Great Hall, Moat
      And Charlie's hand contains Estate, Duchy, Curse
      And Charlie has Lighthouse as a duration
      And Bob has setting autocrat off
      And Charlie has setting autocrat off
      And Bob has setting automoat on
      And my deck contains 3 cards
      And Bob's deck contains 4 cards
      And Charlie's deck is empty
      And it is my Play Action phase
    When I play Bureaucrat
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have put Silver on top of my deck
      And Bob should not need to act
      And Charlie should not need to act
      
      # Buy, not Play Treasure, because nothing blocked the advancement when we checked actions
      And it should be my Buy phase