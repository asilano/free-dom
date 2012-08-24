Feature: Spy
  Attack - Draw 1 card, +1 Action. Each player (including you) reveals the top card of his or her deck and either discards it or puts it back, your choice.

  Background:
    Given I am a player in a standard game with Spy

  Scenario: Spy should be set up at game start
    Then there should be 10 Spy cards in piles
      And there should be 0 Spy cards not in piles

  Scenario: Playing Spy
    Given my hand contains Spy and 4 other cards
      And my deck contains Province, Copper and 5 other cards
      And Bob's deck contains Gold and 3 other cards
      And Charlie's deck is empty
    When I play Spy
      And the game checks actions
    Then I should have drawn 1 card
      And I should be revealing Copper
      And Bob should be revealing Gold
      And Charlie should be revealing nothing
      And I should need to Choose Spy actions for Alan
      And I should need to Choose Spy actions for Bob
      And I should need to Choose Spy actions for Charlie
    When I choose Discard for my revealed Copper
    Then I should have moved Copper from deck to discard
    When I choose Put back for Bob's revealed Gold
    Then nothing should have happened
    When I choose Do nothing for Charlie's revealed nothing
    Then nothing should have happened
      And it should be my Play Action phase


