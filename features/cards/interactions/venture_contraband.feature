Feature: Venture finds Contraband
  The Contraband should be played immediately, before any other treasures can be;
  A contraband can be chosen and should be adhered to.

  Background:
    Given I am a player in a standard game

  Scenario: Venture into Contraband
    Given my hand contains Venture, Gold x3
      And my deck contains Estate, Smithy, Great Hall, Contraband, Moat
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Venture as treasure
      Then the following 2 steps should happen at once
        Then I should have moved Estate, Smithy, Great Hall from deck to discard
        And I should have moved Contraband from deck to play
      And I should have 4 cash
      And Bob should need to Ban Alan from buying a card
      And I should not need to act
    When Bob chooses the Duchy pile
      Then I should need to Play Treasure
    When I play simple treasures
      Then I should have played Gold x3
      Then I should have 13 cash
      And it should be my Buy phase
      And I should be able to choose the Province pile
      And I should not be able to choose the Duchy pile
