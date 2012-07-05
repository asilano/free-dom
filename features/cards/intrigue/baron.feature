Feature: Baron
  +1 Buy. You may discard an Estate card. If you do, +4 cash; otherwise, gain an Estate.
  
  Background:
    Given I am a player in a standard game with Baron
    
  Scenario: Baron should be set up at game start
    Then there should be 10 Baron cards in piles
      And there should be 0 Baron cards not in piles
      
  Scenario: Playing Baron - autobaron off, discard
    Given my hand contains Baron, Estate and 3 other cards
      And it is my Play Action phase
      And I have setting autobaron off
    When I play Baron
    Then I should have 2 buys available
      And I should need to Discard an Estate, or decline to
    When I choose Estate in my hand
    Then I should have discarded Estate
      And I should have 4 cash
      And it should be my Play Treasure phase
      
  Scenario: Playing Baron - autobaron off, don't discard
    Given my hand contains Baron, Estate and 3 other cards
      And it is my Play Action phase
      And I have setting autobaron off
    When I play Baron
    Then I should have 2 buys available
      And I should need to Discard an Estate, or decline to
    When I choose Take Estate in my hand
      And the game checks actions
    Then I should have gained Estate
      And it should be my Buy phase
      
  Scenario: Playing Baron - autobaron on, discard
    Given my hand contains Baron, Estate and 3 other cards
      And it is my Play Action phase
      And I have setting autobaron on
    When I play Baron
    Then I should have discarded Estate
      And I should have 2 buys available      
      And I should have 4 cash
      And it should be my Play Treasure phase
      
  Scenario: Playing Baron - autobaron on, don't discard
    Given my hand contains Baron, Duchy x4
      And it is my Play Action phase
      And I have setting autobaron on
    When I play Baron
    Then I should have 2 buys available      
    When the game checks actions
    Then I should have gained Estate
      And it should be my Buy phase