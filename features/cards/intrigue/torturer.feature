Feature: Torturer
  Attack - Draw 3 cards. Each other player chooses: he discards 2 cards; or he gains a Curse card into his hand.
            
  Background:
    Given I am a player in a standard game with Torturer

  Scenario: Torturer should be set up at game start
    Then there should be 10 Torturer cards in piles
      And there should be 0 Torturer cards not in piles
      
  Scenario: Playing Torturer - both choices, both work
    Given my hand contains Torturer, Duchy x4
      And my deck contains Duchy x4
      And Bob's hand contains Copper, Gold
    When I play Torturer
    Then I should have drawn 3 cards
    When the game checks actions
    Then Bob should need to Choose 'Discard' or 'Gain a Curse'
      And Charlie should need to Choose 'Discard' or 'Gain a Curse'
    When Bob chooses the option Discard 2 cards
    Then Bob should need to Discard 2 cards
    When Bob chooses Copper in his hand
    Then Bob should have discarded Copper
      And Bob should need to Discard a card
    When Bob chooses Gold in his hand
    Then Bob should have discarded Gold
    When Charlie chooses the option Gain a Curse
      And the game checks actions
    Then Charlie should have placed Curse in his hand
      And it should be my Buy phase
    
  Scenario: Playing Torturer - both choices, both are null
    Given my hand contains Torturer, Duchy x4
      And my deck contains Duchy x4
      And Bob's hand is empty
      And the Curse pile is empty   # Curses empty causes order-relevant atm
    When I play Torturer
    Then I should have drawn 3 cards
    When the game checks actions
    Then Bob should need to Choose 'Discard' or 'Gain a Curse'      
    When Bob chooses the option Discard 2 cards
    Then nothing should have happened
    When the game checks actions
    Then Charlie should need to Choose 'Discard' or 'Gain a Curse'
    When Charlie chooses the option Gain a Curse
      And the game checks actions
    Then it should be my Buy phase
    
  Scenario: Playing Torturer - autotorture for curses on
    Given my hand contains Torturer, Duchy x4
      And my deck contains Duchy x4
      And Bob's hand contains Copper
      And Charlie has setting autotorture on
    When I play Torturer
    Then I should have drawn 3 cards
    When the game checks actions
    Then Charlie should have placed Curse in his hand
      And Bob should need to Choose 'Discard' or 'Gain a Curse'      
    When Bob chooses the option Discard 2 cards
    Then Bob should need to Discard a card
    When Bob chooses Copper in his hand
    Then Bob should have discarded Copper
      And it should be my Play Treasure phase