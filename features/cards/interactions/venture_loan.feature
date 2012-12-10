Feature: Venture finds Loan
  The Loan should be played immediately, before any other treasures can be;
  The next treasure down gets trashed / discarded

  Background:
    Given I am a player in a standard game

  Scenario: Venture into Contraband
    Given my hand contains Venture, Gold x3
      And my deck contains Estate, Smithy, Loan, Great Hall, Silver, Moat
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then I should need to Play Treasure
    When I play Venture as treasure
      Then the following 3 steps should happen at once
        Then I should have moved Estate, Smithy from deck to discard
        And I should have moved Loan from deck to play
        And I should have moved Great Hall from deck to discard
      And I should be revealing Silver
      And I should need to Choose to Trash or Discard Silver
      And I should have 2 cash
    When I choose Trash for my revealed Silver
      Then I should have removed Silver from my deck
      And I should need to Play treasure
