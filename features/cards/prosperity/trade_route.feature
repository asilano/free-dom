Feature: Trade Route
  +1 Buy, +1 Cash per token on the Trade Route mat. Trash a card from your hand. 
    Setup: Put a token on each Victory card Supply pile. 
    When a card is gained from that pile, move the token to the Trade Route mat.
    
  Background:
    Given I am a player in a standard game with Trade Route, Gardens, Island, Harem, Mine
    
  Scenario: Trade Route should be set up at game start
    Then there should be 10 Trade Route cards in piles
      And there should be 0 Trade Route cards not in piles
      And the game fact "trade route value" should be 0
      And the "trade route token" state of the Estate pile should be true
      And the "trade route token" state of the Duchy pile should be true
      And the "trade route token" state of the Province pile should be true
      And the "trade route token" state of the Gardens pile should be true
      And the "trade route token" state of the Island pile should be true
      And the "trade route token" state of the Harem pile should be true
      And the Trade Route pile should have no "trade route token" state      
      And the Silver pile should have no "trade route token" state
      
  Scenario: Buying changes facts and state
    Given my hand contains Market, Woodcutter, Gold, Gold
      And my deck contains Estate x5
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Woodcutter
    And the game checks actions
      Then I should have played Gold x2
      And it should be my Buy phase
      And I should have 3 buys available
      And I should have 9 cash
    When I buy Estate
      # Increments on gain, not buy
      Then the game fact "trade route value" should be 0
    When the game checks actions
      Then I should have gained Estate
      And the game fact "trade route value" should be 1
      And the "trade route token" state of the Estate pile should be false
    When I buy Copper
    And the game checks actions
      Then I should have gained Copper
      And the game fact "trade route value" should be 1
    When I buy Island
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have gained Island
        And I should have discarded Estate
        And I should have moved Market, Woodcutter, Gold x2 from play to discard
        And I should have drawn 5 cards
      And the game fact "trade route value" should be 2
      And the "trade route token" state of the Island pile should be false        
    
  Scenario: Playing Trade Route; choice in hand
    Given my hand contains Trade Route, Estate, Copper
      And the game fact "trade route value" is 2
      And it is my Play Action phase
    When I play Trade Route
      Then I should have 2 cash
      And I should have 2 buys available
      And I should need to Trash a card with Trade Route
    When I choose Copper in my hand
      Then I should have removed Copper from my hand
      And it should be my Play Treasure phase
  
  Scenario: Playing Trade Route; ony one type in hand
    Given my hand contains Trade Route, Estate x2
      And the game fact "trade route value" is 1
      And it is my Play Action phase
    When I play Trade Route
      Then I should have removed Estate from my hand
      And I should have 2 buys available
      And I should have 1 cash
      And it should be my Play Treasure phase
  
  Scenario: Playing Trade Route; nothing in hand
    Given my hand contains Trade Route
      And the game fact "trade route value" is 3
      And it is my Play Action phase
    When I play Trade Route
      Then I should have 3 cash
      And I should have 2 buys available
      And it should be my Play Treasure phase
       
  Scenario: Gains of all types change facts and state
    Given my hand contains Upgrade, Smithy
      And it is my Play Action phase
    When I play Upgrade
      Then I should have drawn a card
      And I should need to Upgrade a card
    When I choose Smithy in my hand
      Then I should have removed Smithy from my hand
      And I should need to Take a replacement card with Upgrade
    When I choose the Duchy pile
    And the game checks actions
      Then I should have gained Duchy
      And the game fact "trade route value" should be 1
      And the "trade route token" state of the Duchy pile should be false
