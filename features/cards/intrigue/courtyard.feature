Feature: Courtyard
  Draw 3 cards. Put a card from your hand on top of your deck.
  
  Background:
    Given I am a player in a standard game with Courtyard
    
  Scenario: Courtyard should be set up at game start
    Then there should be 10 Courtyard cards in piles
      And there should be 0 Courtyard cards not in piles
      
  Scenario: Playing Courtyard
    Given my hand contains Courtyard, Copper, Silver
      And my deck contains Estate, Duchy, Province, Curse
    When I play Courtyard
    Then I should have drawn 3 cards
      And I should need to Place a card on deck with Courtyard
      And I should not be able to choose a nil action in my hand
    When I choose Silver in my hand
    Then I should have put Silver from my hand on top of my deck
      And it should be my Play Treasure phase
      
  Scenario: Playing Courtyard - deck too small
    Given my hand contains Courtyard, Copper, Silver
      And my deck contains Estate
      And I have noted the last history
    When I play Courtyard
    Then I should have drawn 1 card
      And later history should include "[I] tried to draw 2 more cards, but their deck was empty."
      And I should need to Place a card on deck with Courtyard
      And I should not be able to choose a nil action in my hand
    When I choose Silver in my hand
    Then I should have put Silver from my hand on top of my deck
      And it should be my Play Treasure phase
      
  Scenario: Playing Courtyard - empty hand after play
    Given my hand contains Courtyard
      And my deck is empty
      And I have noted the last history
    When I play Courtyard
    Then later history should include "[I] tried to draw 3 more cards, but their deck was empty."
      And I should need to Place a card on deck with Courtyard
      And I should be able to choose a nil action in my hand
    When I choose Place nothing in my hand
    Then it should be my Play Treasure phase      
      
