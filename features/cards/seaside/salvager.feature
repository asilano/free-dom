Feature: Salvager
  +1 Buy. Trash a card from your hand. +Cash equal to its cost.

  Background:
    Given I am a player in a standard game with Salvager, Mint
    # Mint to hold up autoplay of treasure

  Scenario: Salvager should be set up at game start
    Then there should be 10 Salvager cards in piles
      And there should be 0 Salvager cards not in piles

  Scenario: Playing Salvager - choices in hand 
    Given my hand contains Salvager, Copper, Estate and 2 other cards
      And it is my Play Action phase
    When I play Salvager
      Then I should need to Trash a card with Salvager
    When I choose Estate in my hand
      Then I should have removed Estate from my hand
      And I should have 2 cash available
      And I should have 2 buys available
      And it should be my Play Treasure phase

  Scenario: Playing Salvager - only one type in hand
    Given my hand contains Salvager, Gold x2
      And it is my Play Action phase
    When I play Salvager
      Then I should have removed Gold from my hand
      And I should have 6 cash available
      And I should have 2 buys available
      And it should be my Play Treasure phase

  Scenario: Playing Salvager - nothing in hand
    Given my hand contains Salvager
      And it is my Play Action phase
    When I play Salvager
      Then nothing should have happened
      And I should have 0 cash available
      And I should have 2 buys available
      And it should be my Play Treasure phase
