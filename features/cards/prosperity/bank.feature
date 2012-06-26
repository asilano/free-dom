Feature: Bank
  Treasure - When you play this, it's worth 1 Cash per Treasure card you have in play (including this).
  
  Background:
    Given I am a player in a standard game with Bank
    
  Scenario: Bank should be set up at game start
    Then there should be 10 Bank cards in piles
      And there should be 0 Bank cards not in piles
      
  Scenario: Playing Bank
    Given my hand contains Copper, Harem, Bank, Bank, Silver
      And it is my Play Treasure phase
    When I play Copper as treasure
      And I play Harem as treasure
    Then I should have 3 cash
    When I play Bank as treasure
    Then I should have 6 cash
    When I play Bank as treasure
    Then I should have 10 cash
    When I play Silver as treasure
    Then I should have 12 cash
      And it should be my Buy phase 