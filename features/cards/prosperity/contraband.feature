Feature: Contraband
  Treasure - 3 Cash, +1 Buy. When you play this, the next player names a card. You can't buy that card this turn.
  
  Background:
    Given I am a player in a standard game with Contraband
    
  Scenario: Contraband should be set up at game start
    Then there should be 10 Contraband cards in piles
      And there should be 0 Contraband cards not in piles
      
  Scenario: Playing Contraband
    Given my hand contains Contraband, Contraband, Contraband, Copper, Silver
      And it is my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then I should need to Play Treasure
    When I play Contraband as treasure
    Then I should have 3 cash
      And I should have 2 buys available
      And Bob should need to Ban Alan from buying a card
    When Bob chooses the Duchy pile
    Then I should need to Play Treasure
    When I play Contraband as treasure
    Then I should have 6 cash
      And I should have 3 buys available
      And Bob should need to Ban Alan from buying a card
    When Bob chooses the Silver pile
    Then I should need to Play Treasure
    When I play Contraband as treasure
    Then I should have 9 cash
      And I should have 4 buys available
      And Bob should need to Ban Alan from buying a card
    When Bob chooses Ban 'Ace of Spades' for piles
      Then I should need to Play Treasure
    When I play simple treasures
    Then I should have moved Copper, Silver from hand to play
      And I should have 12 cash
      And I should have 4 buys available
      And it should be my Buy phase
      And I should be able to choose the Copper, Gold, Estate, Province piles
      And I should not be able to choose the Silver, Duchy piles 