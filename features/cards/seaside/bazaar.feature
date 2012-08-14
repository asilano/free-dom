Feature: Bazaar
  Draw 1 card, +2 Actions, +1 Cash.
    
  Background:
    Given I am a player in a standard game with Bazaar
  
  Scenario: Bazaar should be set up at game start
    Then there should be 10 Bazaar cards in piles
      And there should be 0 Bazaar cards not in piles
  
  Scenario: Playing Bazaar
    Given my hand contains Bazaar and 4 other cards
      And it is my Play Action phase
    When I play Bazaar
    Then I should have drawn 1 card
      And I should have 2 actions available
      And I should have 1 cash
      And it should be my Play Action phase
      
  Scenario: Playing multiple Bazaars
    Given my hand contains Bazaar x2 and 3 other cards
      And it is my Play Action phase
    When I play Bazaar
    Then I should have drawn 1 card
      And I should have 2 actions available
      And I should have 1 cash
      And it should be my Play Action phase
    When I play Bazaar
    Then I should have drawn 1 card
      And I should have 3 actions available
      And I should have 2 cash
      And it should be my Play Action phase
