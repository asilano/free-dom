Feature: Chancellor
  +2 Cash. You may immediately put your deck onto your discard pile.

  Background:
    Given I am a player in a standard game with Chancellor

  Scenario: Chancellor should be set up at game start
    Then there should be 10 Chancellor cards in piles
      And there should be 0 Chancellor cards not in piles

  Scenario: Playing Chancellor - choose not to discard deck
    Given my hand contains Chancellor and 4 other cards
      And my deck contains 6 cards
      And I have 3 cards in discard
      And it is my Play Action phase
    When I play Chancellor
    Then I should have 2 cash
      And I should need to Choose whether to discard your deck, with Chancellor
    When I choose the option Don't discard
    Then it should be my Play Treasure phase

  Scenario: Playing Chancellor - choose to discard deck
    Given my hand contains Chancellor and 4 other cards
      And my deck contains 6 cards named "deck"
      And I have 3 cards in discard named "discard"
      And it is my Play Action phase
    When I play Chancellor
    Then I should have 2 cash
      And I should need to Choose whether to discard your deck, with Chancellor
    When I choose the option Discard deck
    Then I should have moved the cards named "deck" from deck to discard
      And it should be my Play Treasure phase

  Scenario: Playing Chancellor - choose to discard empty deck
    Given my hand contains Chancellor and 4 other cards
      And my deck is empty
      And I have 3 cards in discard named "discard"
      And it is my Play Action phase
    When I play Chancellor
    Then I should have 2 cash
      And I should need to Choose whether to discard your deck, with Chancellor
    When I choose the option Discard deck
    Then it should be my Play Treasure phase