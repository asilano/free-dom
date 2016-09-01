Feature: Chapel
  Trash up to 4 cards from your hand

  Background:
    Given I am a player in a standard game with Chapel

  Scenario: Chapel should be set up at game start
    Then there should be 10 Chapel cards in piles
      And there should be 0 Chapel cards not in piles

  Scenario: Playing Chapel - trashing 4
    Given my hand contains Chapel, Copper, Silver, Gold, Curse, Estate
      And it is my Play Action phase
    When I play Chapel
      Then I should need to Trash up to 4 cards with Chapel
    When I choose Curse, Estate, Copper, Silver in my hand
      Then I should have removed Curse, Estate, Copper, Silver from my hand
      And it should be my Play Treasure phase

  Scenario: Playing Chapel - trashing 2
    Given my hand contains Chapel, Copper, Silver, Gold, Curse, Estate
      And it is my Play Action phase
    When I play Chapel
      Then I should need to Trash up to 4 cards with Chapel
    When I choose Curse, Estate in my hand
      Then I should have removed Curse, Estate from my hand
      And it should be my Play Treasure phase
      And there should be 1 Curse card in trash
      And there should be 1 Estate card in trash