Feature: Warehouse
  Draw 3 cards. +1 Action. Discard 3 cards.
  
  Background:
    Given I am a player in a standard game with Warehouse
  
  Scenario: Warehouse should be set up at game start
    Then there should be 10 Warehouse cards in piles
      And there should be 0 Warehouse cards not in piles
  
  Scenario: Playing Warehouse
    Given my hand contains Warehouse, Estate x2, Gold x2
      And my deck contains Silver x4
      And it is my Play Action phase
    When I play Warehouse
    Then I should have drawn 3 cards
      And I should need to Discard 3 cards
      And I should not be able to choose a nil action in my hand
    When I choose Estate in my hand
      Then I should have discarded Estate
      And I should need to Discard 2 cards
      And I should not be able to choose a nil action in my hand
    When I choose Estate in my hand
      Then I should have discarded Estate
      And I should need to Discard 1 card
      And I should not be able to choose a nil action in my hand
    When I choose Silver in my hand
      Then I should have discarded Silver
    Then it should be my Play Action phase
      And I should have 1 action available
      
  Scenario: Playing Warehouse with only one kind of card in hand auto-discards 3 of them
    Given my hand contains Warehouse, Gold x4
      And my deck contains Gold x5
      And it is my Play Action phase
    When I play Warehouse
    Then the following 3 steps should happen at once
      Then I should have drawn 3 cards
      And I should have discarded Gold, Gold, Gold
    Then it should be my Play Action phase
      And I should have 1 action available
      
  Scenario: Playing Warehouse with small deck and full discard causes reshuffle
    Given my hand contains Warehouse, Gold x4
      And my deck contains Gold
      And I have Gold x4 in my discard
      And it is my Play Action phase
    When I play Warehouse
    Then the following 3 steps should happen at once
      Then I should have drawn 3 cards
      And I should have shuffled my discards
      And I should have discarded Gold, Gold, Gold
    Then it should be my Play Action phase
      And I should have 1 action available
  
  Scenario: Playing Warehouse with small deck and no discard draws as many as possible
    Given my hand contains Warehouse, Gold
      And my deck contains Gold
      And I have nothing in my discard
      And it is my Play Action phase
    When I play Warehouse
    Then the following 3 steps should happen at once
      Then I should have drawn 2 cards
      And I should have shuffled my discards
      And I should have discarded Gold, Gold
    Then it should be my Play Action phase
      And I should have 1 action available
  
  Scenario: Playing Warehouse with not enough cards to discard afterwards (auto-discard)
    Given my hand contains Warehouse, Estate
      And my deck is empty
      And I have nothing in my discard
      And it is my Play Action phase
    When I play Warehouse
      Then I should have discarded Estate
    Then it should be my Play Action phase
      And I should have 1 action available
