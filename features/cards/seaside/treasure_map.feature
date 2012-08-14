Feature: Treasure Map
  Trash this and another copy of Treasure Map from your hand. If you do trash two Treasure Maps, gain 4 Gold cards, putting them on top of your deck.
    
  Background:
    Given I am a player in a standard game with Treasure Map
  
  Scenario: Treasure Map should be set up at game start
    Then there should be 10 Treasure Map cards in piles
      And there should be 0 Treasure Map cards not in piles

  Scenario: Playing Treasure Map - one or more Maps in hand
    Given my hand contains Treasure Map x2, Estate
      And it is my Play Action phase
    When I play Treasure Map
      Then the following 2 steps should happen at once
        Then I should have removed Treasure Map from my play
        And I should have removed Treasure Map from my hand
    When the game checks actions
      Then I should have gained Gold x4 to my deck
    And it should be my Buy phase
      
  Scenario: Playing Treasure Map - no other Maps in hand
    Given my hand contains Treasure Map, Treasury, Market, Harem, Gold
      And it is my Play Action phase
    When I play Treasure Map
      Then I should have removed Treasure Map from my play
      And it should be my Play Treasure phase

  Scenario: Playing Treasure Map with Throne Room and more Maps in hand
    # Each play of the Throned Map trashes another Map from hand, but only one of them gives the Gold
    Given my hand contains Throne Room, Treasure Map x4
      And it is my Play Action phase
    When I play Throne Room
      And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have removed Treasure Map x3 from my hand
        And I should have gained Gold x4 to my deck
      And it should be my Buy phase

  Scenario: Playing Treasure Map with Throne Room but no other Maps in hand
    # Trashes TM, gives no gold
    Given my hand contains Throne Room, Treasure Map, Estate x3
      And it is my Play Action phase
    When I play Throne Room
      And the game checks actions
    Then I should have removed Treasure Map from my hand
      And it should be my Buy phase
