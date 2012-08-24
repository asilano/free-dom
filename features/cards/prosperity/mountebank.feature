Feature: Mountebank
  Attack - +2 Cash. Each other player may discard a Curse. If he doesn't, he gains a Curse and a Copper.
    
  Background:
    Given I am a player in a standard game with Mountebank
  
  Scenario: Mountebank should be set up at game start
    Then there should be 10 Mountebank cards in piles
      And there should be 0 Mountebank cards not in piles

  Scenario: Playing Mountebank - automountebank off, choosing to discard
    Given my hand contains Mountebank and 4 other cards
      And Bob's hand contains Copper x5
      And Charlie's hand contains Gold, Village, Curse, Copper
      And Bob has setting automountebank off
      And Charlie has setting automountebank off
      And it is my Play Action phase
    When I play Mountebank
    Then I should have 2 cash
    When the game checks actions
    Then Bob should have gained Curse, Copper
      And Charlie should need to Discard a Curse
      And I should not need to act
    When Charlie chooses Curse in his hand
    Then Charlie should have discarded Curse
      And it should be my Play Treasure phase      
        
  Scenario: Playing Mountebank - automountebank off, choosing not to discard
    Given my hand contains Mountebank
      And Bob's hand is empty
      And Charlie's hand contains Gold, Village, Curse, Copper
      And Bob has setting automountebank off
      And Charlie has setting automountebank off
      And it is my Play Action phase
    When I play Mountebank
    Then I should have 2 cash
    When the game checks actions
    Then Bob should have gained Curse, Copper
      And Charlie should need to Discard a Curse
      And I should not need to act
    When Charlie chooses Discard nothing in his hand
      And the game checks actions
    Then Charlie should have gained Curse, Copper
      And it should be my Buy phase      
      
  Scenario: Playing Mountebank - automountebank on
    Given my hand contains Mountebank
      And Bob's hand contains Copper x5
      And Charlie's hand contains Gold, Village, Curse, Copper
      And Bob has setting automountebank on
      And Charlie has setting automountebank on
      And it is my Play Action phase
    When I play Mountebank
    Then I should have 2 cash
    When the game checks actions
    Then the following 2 steps should happen at once
      Then Bob should have gained Curse, Copper
      And Charlie should have discarded Curse
    And it should be my Buy phase   
        
  Scenario: Playing Mountebank - attack prevented by (Moat/Lighthouse)
    Given my hand contains Mountebank
      And Bob's hand contains Copper x4, Moat
      And Charlie's hand contains Gold, Village, Curse, Copper
      And Charlie has Lighthouse as a duration            
      And Bob has setting automoat on      
      And it is my Play Action phase
    When I play Mountebank
    Then I should have 2 cash
    When the game checks actions
    Then Bob should not need to act
      And Charlie should not need to act
      And it should be my Buy phase