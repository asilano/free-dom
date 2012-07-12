Feature: Caravan
  Draw 1 card, +1 Action.
  At the start of your next turn: Draw 1 card.
  
  Background:
    Given I am a player in a standard game with Caravan
    
  Scenario: Caravan should be set up at game start
    Then there should be 10 Caravan cards in piles
      And there should be 0 Caravan cards not in piles
      
  Scenario: Playing Caravan
    Given my hand contains Caravan and 4 other cards
      And it is my Play Action phase
    When I play Caravan
    Then I should have drawn a card
      And I should have 1 action available
    When my next turn starts
    Then the following 2 steps should happen at once
      Then I should have moved Caravan from enduring to play
      And I should have drawn a card
    And I should have 6 cards in hand
    And I should have 1 action available
      
  Scenario: Playing multiple Caravans
    Given my hand contains Caravan x2 and 3 other cards
      And it is my Play Action phase
    When I play Caravan
    Then I should have drawn a card
      And I should have 1 action available
    When I play Caravan
    Then I should have drawn a card
      And I should have 1 action available
    When my next turn starts
    Then the following 2 steps should happen at once
      Then I should have moved Caravan x2 from enduring to play
      And I should have drawn 2 cards
    And I should have 7 cards in hand
    And I should have 1 action available