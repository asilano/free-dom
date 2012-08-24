Feature: Embargo
  +2 Cash. Trash this card. Put an Embargo token on top of a Supply pile. 
  When a player buys a card, he gains a Curse card per Embargo token on that pile.
  
  Background:
    Given I am a player in a standard game with Embargo
    
  Scenario: Embargo should be set up at game start
    Then there should be 10 Embargo cards in piles
      And there should be 0 Embargo cards not in piles
      
  Scenario: Playing Embargo; buying from an Embargoed pile
    Given my hand contains Embargo
      And my deck contains Duchy x5
      And it is my Play Action phase
    When I play Embargo
    Then I should have removed Embargo from my play
    And I should need to Choose a pile to Embargo
      And I should be able to choose the Copper, Silver, Gold, Estate, Province, Embargo piles
    When I choose the Estate pile
      Then I should have 2 cash
      And there should be 1 Embargo card not in hands, piles, decks
    When the game checks actions
      Then it should be my Buy phase
    When I buy Estate
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have drawn 5 cards
      And I should have gained Estate, Curse
    
  Scenario: Buying from a multiply Embargoed pile
    Given my hand contains Embargo x2, Workers' Village
      And my deck contains Duchy x5
      And it is my Play Action phase
    When I play Workers' Village
      Then I should have drawn 1 card
      And I should have 2 buys available
    When I play Embargo
    Then I should have removed Embargo from my play
    And I should need to Choose a pile to Embargo
      And I should be able to choose the Copper, Silver, Gold, Estate, Province, Embargo piles
    When I choose the Silver pile
      Then I should have 2 cash
      And I should have 1 action available
    When I play Embargo
    Then I should have removed Embargo from my play
    And I should need to Choose a pile to Embargo
      And I should be able to choose the Copper, Silver, Gold, Estate, Province, Embargo piles
    When I choose the Silver pile
      Then I should have 4 cash
      And I should have 0 actions available
    When the game checks actions
      Then it should be my Buy phase
    When I buy Silver
      And the game checks actions
      Then I should have gained Silver, Curse x2
      
      
  Scenario: Embargo does not apply to non-Buy gains
    # Checks that gains from Mine, Bureaucrat and Smuggler don't get curses from Embargo
    Given my hand contains Workers' Village, Embargo, Mine, Copper, Estate
      And my deck contains Smithy x10
      And Bob's hand contains Bureaucrat
      And Charlie's hand contains Smuggler
      And it is my Play Action phase
    When I play Workers' Village
      Then I should have drawn a card
    When I play Embargo
      Then I should have removed Embargo from my play
      And I should need to Choose a pile to Embargo
    When I choose the Silver pile
      Then I should have 2 cash
      
    When I play Mine
    Then I should have removed Copper from hand
      And I should need to Take a replacement card with Mine
    When I choose the Silver pile
      And the game checks actions
      Then I should have gained Silver to play
      # because we're out of actions
      And there should be 0 Curse cards in hand, discard, deck
      And it should be my Buy phase
      And I should have 4 cash
      
    When I buy Silver
      And the game checks actions
      Then I should have gained Silver, Curse
      
    When Bob's next turn starts
    And Bob plays Bureaucrat
      And the game checks actions
      Then Bob should have put Silver on top of his deck
      And there should be 1 Curse card in hand, discard, deck
      # the one I gained earlier - i.e. no more for Bob
      
    When Charlie's next turn starts
    And Charlie plays Smuggler 
      And the game checks actions
    Then Charlie should have gained Silver
      And there should be 1 Curse card in hand, discard, deck
      # the one I gained earlier - i.e. no more for Charlie
      