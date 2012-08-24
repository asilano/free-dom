Feature: Pearl Diver
  Draw 1 card, +1 Action.
  Look at the bottom card of your deck. You may put it on top.
  
  Background:
    Given I am a player in a standard game with Pearl Diver
    
  Scenario: Pearl Diver should be set up at game start
    Then there should be 10 Pearl Diver cards in piles
      And there should be 0 Pearl Diver cards not in piles
      
  Scenario: Playing Pearl Diver - move to the top
    Given my hand contains Pearl Diver, Village, Estate x3
      And my deck contains Copper, Silver, Gold, Estate, Duchy, Province
      And it is my Play Action phase
    When I play Pearl Diver
      Then I should have drawn 1 card
      And I should have 1 action available
      And I should need to Choose whether to move the seen card with Pearl Diver
      And I should have seen Province
    When I choose the option Move Province to top of deck
      Then I should have Province, Silver, Gold, Estate, Duchy in my deck
    When I play Village
      Then I should have drawn 1 card
      And I should have Estate, Estate, Estate, Copper, Province in my hand
      
  Scenario: Playing Pearl Diver - decline to move
    Given my hand contains Pearl Diver, Village, Estate x3
      And my deck contains Copper, Silver, Gold, Estate, Duchy, Province
      And it is my Play Action phase
    When I play Pearl Diver
      Then I should have drawn 1 card
      And I should have 1 action available
      And I should need to Choose whether to move the seen card with Pearl Diver
      And I should have seen Province
    When I choose the option Leave Province on bottom of deck
      Then I should have Silver, Gold, Estate, Duchy, Province in my deck
    When I play Village
      Then I should have drawn 1 card
      And I should have Estate, Estate, Estate, Copper, Silver in my hand

  Scenario: Playing Pearl Diver with 1 card in deck (after draw) - get no option
    Given my hand contains Pearl Diver and 4 other cards
      And my deck contains Duchy x2
      And it is my Play Action phase
    When I play Pearl Diver
      Then I should have drawn 1 card
      And I should have Duchy in my deck
      And I should have 1 action available
      And it should be my Play Action phase
  
  Scenario: Playing Pearl Diver with 0 cards in deck and 0 cards in discard
    Given my hand contains Pearl Diver and 4 other cards
      And my deck is empty
      And I have nothing in discard
      And it is my Play Action phase
    When I play Pearl Diver
      Then I should have 1 action available
      And it should be my Play Action phase
  
  Scenario: Playing Pearl Diver with 0 cards in deck (after draw) and multiple cards in discard
    Given my hand contains Pearl Diver, Village
      And my deck contains Estate
      And I have Copper, Silver, Gold in discard
      And it is my Play Action phase
    When I play Pearl Diver
      Then the following 2 steps should happen at once
        Then I should have drawn 1 card
        And I should have shuffled my discards
    And I should have 1 action available
      And I should need to Choose whether to move the seen card with Pearl Diver
      And I should have seen Silver
    When I choose the option Leave Silver on bottom of deck
      Then I should have Copper, Gold, Silver in my deck
    When I play Village
      Then I should have drawn 1 card
      And I should have Estate, Copper in my hand
