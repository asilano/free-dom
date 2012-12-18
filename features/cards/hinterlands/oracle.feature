Feature: Oracle
  Each player (including you) reveals the top 2 cards of his deck, and you choose one: either he discards them, or he puts
  them back on top in an order he chooses.
  Draw 2 cards.

  Background:
    Given I am a player in a standard game with Oracle

  Scenario: Oracle should be set up at game start
    Then there should be 10 Oracle cards in piles
    And there should be 0 Oracle cards not in piles
    And the Oracle pile should cost 3

  Scenario: Playing Oracle part 1
    Given my hand contains Oracle, Bank
      And my deck contains Gold, Silver
      And Bob's deck contains Platinum, Market
      And Charlie's deck contains Curse, Estate
      And it is my Play Action phase
    When I play Oracle
    And the game checks actions
      Then I should be revealing Gold, Silver
      And Bob should be revealing Platinum, Market
      And Charlie should be revealing Curse, Estate
      And I should need to Choose Oracle effect for Alan's revealed cards
      And I should need to Choose Oracle effect for Bob's revealed cards
      And I should need to Choose Oracle effect for Charlie's revealed cards
    When I choose the option Put back
      Then I should need to Put a card 2nd from top with Oracle
    When I choose Place 2nd for my revealed Gold
      Then I should have Silver, Gold in my deck
    When I choose for Bob the option Discard
      Then Bob should have moved Platinum, Market from his deck to discard
    When I choose for Charlie the option Put back
      Then Charlie should need to Put a card 2nd from top with Oracle
    When Charlie chooses Put on deck for his revealed Estate
      Then Charlie should have Curse, Estate in his deck
    When the game checks actions
      Then I should have drawn 2 cards
      And it should be my Play Treasure phase

  Scenario: Playing Oracle part 2
    Given my hand contains Oracle, Bank
      And my deck is empty
      And Bob's deck is empty
      And Charlie's deck contains Curse
      And it is my Play Action phase
    When I play Oracle
    And the game checks actions
      Then I should be revealing nothing
      And Bob should be revealing nothing
      And Charlie should be revealing Curse
      And I should need to Choose Oracle effect for Charlie's revealed cards
    When I choose for Charlie the option Put back
      Then Charlie should have Curse in his deck
    When the game checks actions
      Then it should be my Play Treasure phase

  Scenario: Playing Oracle part 3
    Given my hand contains Oracle, Bank
      And my deck contains Estate
      And Bob's deck is empty
      And Charlie's deck contains Curse
      And it is my Play Action phase
    When I play Oracle
    And the game checks actions
      Then I should be revealing Estate
      And Bob should be revealing nothing
      And Charlie should be revealing Curse
      And I should need to Choose Oracle effect for Alan's revealed cards
      And I should need to Choose Oracle effect for Charlie's revealed cards
    When I choose for Charlie the option Discard
      Then Charlie should have moved Curse from his deck to discard
    When I choose the option Discard
      Then I should have moved Estate from my deck to discard
    When the game checks actions
      Then I should have drawn 2 cards
      And it should be my Play Treasure phase
