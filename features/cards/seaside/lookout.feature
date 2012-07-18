Feature: Lookout
  +1 Action. 
  Look at the top 3 cards of your deck. Trash one of them. Discard one of them. Put the other one on top of your deck.
  
  Background:
    Given I am a player in a standard game with Lookout
    
  Scenario: Lookout should be set up at game start
    Then there should be 10 Lookout cards in piles
      And there should be 0 Lookout cards not in piles
      
  Scenario: Playing Lookout 
    Given my hand contains Lookout 
      And it is my Play Action phase
      And my deck contains Province, Curse, Gold, Duchy x5
    When I play Lookout
      Then I should have seen Province, Curse, Gold
      And I should need to Decide where to place each card, with Lookout
    When I choose the matrix Trash the Curse, Deck the Gold, Discard the Province
      Then the following 2 steps should happen at once
        Then I should have removed Curse from my deck
        And I should have moved Province from deck to discard
      And I should have 1 action available
      And it should be my Play Action phase
    
  Scenario: Playing Lookout - all the same
    Given my hand contains Lookout 
      And it is my Play Action phase
      And my deck contains Estate x3, Duchy x5
    When I play Lookout
      Then I should have seen Estate x3
      And I should need to Decide where to place each card, with Lookout
    When I choose the matrix Trash the Estate, Discard the Estate, Deck the Estate
      Then the following 2 steps should happen at once
        Then I should have removed Estate from my deck
        And I should have moved Estate from deck to discard
      And I should have 1 action available
      And it should be my Play Action phase
    
  Scenario: Playing Lookout - reshuffles if insufficient deck
    Given my hand contains Lookout 
      And it is my Play Action phase
      And my deck contains Province
      And I have Gold, Curse in my discard
    When I play Lookout
      Then I should have shuffled my discards
      And I should have seen Province, Gold, Curse
      And I should need to Decide where to place each card, with Lookout
    
  Scenario: Playing Lookout - 2 cards in deck
    Given my hand contains Lookout 
      And it is my Play Action phase
      And my deck contains Province, Gold
    When I play Lookout
      And I should have seen Province, Gold
      Then I should need to Decide where to place each card, with Lookout
    When I choose the matrix Trash the Gold, Discard the Province
      Then the following 2 steps should happen at once
        Then I should have removed Gold from my deck
        And I should have moved Province from deck to discard
      And I should have 1 action available
      And it should be my Play Action phase
    
  Scenario: Playing Lookout - 1 card in deck
    Given my hand contains Lookout 
      And it is my Play Action phase
      And my deck contains Curse
    When I play Lookout
      Then I should have removed Curse from my deck
      And I should have 1 action available
      And it should be my Play Action phase
    
  Scenario: Playing Lookout - no cards in deck
    Given my hand contains Lookout 
      And it is my Play Action phase
      And my deck is empty
    When I play Lookout
      Then I should have 1 action available
      And it should be my Play Action phase
