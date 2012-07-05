Feature: Steward
  Choose one: Draw 2 cards; or +2 Cash; or trash 2 cards from your hand 
  
  Background:
    Given I am a player in a standard game with Steward
  
  Scenario: Steward should be set up at game start
    Then there should be 10 Steward cards in piles
      And there should be 0 Steward cards not in piles

  Scenario: Playing Steward - choose draw
    Given my hand contains Steward and 4 other cards
      And my deck contains 6 cards
      And it is my Play Action phase
    When I play Steward
    Then I should need to Choose Steward's effect
    When I choose the option Draw two
    Then I should have drawn 2 cards
      And it should be my Play Treasure phase
      
  Scenario: Playing Steward - choose cash
    Given my hand contains Steward and 4 other cards
      And my deck contains 6 cards
      And it is my Play Action phase
    When I play Steward
    Then I should need to Choose Steward's effect
    When I choose the option Two cash
    Then I should have 2 cash
      And it should be my Play Treasure phase
      
  Scenario: Playing Steward - choose trash
    Given my hand contains Steward, Copper, Curse and 2 other cards
      And my deck contains 6 cards
      And it is my Play Action phase
    When I play Steward
    Then I should need to Choose Steward's effect
    When I choose the option Trash two
    Then I should need to Trash 2 cards with Steward
    When I choose Copper in my hand
    Then I should have removed Copper from my hand
      And I should need to Trash a card with Steward
    When I choose Curse in my hand
    Then I should have removed Curse from my hand
      And it should be my Play Treasure phase
      
  Scenario: Playing Steward - choose trash, one in hand
    Given my hand contains Steward, Copper
      And my deck contains 6 cards
      And it is my Play Action phase
    When I play Steward
    Then I should need to Choose Steward's effect
    When I choose the option Trash two
    Then I should need to Trash a card with Steward
    When I choose Copper in my hand
    Then I should have removed Copper from my hand    
      And it should be my Play Treasure phase
      
  Scenario: Playing Steward - choose trash, none in hand
    Given my hand contains Steward
      And my deck contains 6 cards
      And it is my Play Action phase
    When I play Steward
    Then I should need to Choose Steward's effect
    When I choose the option Trash two
    Then it should be my Play Treasure phase