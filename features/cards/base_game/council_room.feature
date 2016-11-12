Feature: Council Room
  Draw 4 cards, +1 Buy. Each other player draws a card

  Background:
    Given I am a player in a standard game with Council Room

  Scenario: Council Room should be set up at game start
    Then there should be 10 Council Room cards in piles
      And there should be 0 Council Room cards not in piles

  Scenario Outline: Playing Council Room when other players have decks
    Given my hand contains Council Room, Copper and 3 other cards
      And my deck contains <deck size> cards
      And I have <discard size> cards in discard
      And Bob's deck contains <bob deck> cards
      And Charlie's deck contains <chas deck> cards
      And Bob has <bob discard> cards in discard
      And Charlie has <chas discard> cards in discard
      And it is my Play Action phase
    When I play Council Room
    Then the following 3 steps should happen at once
      Then I should have drawn <drawn> cards
      And Bob should have drawn <bob drawn> cards
      And Charlie should have drawn <chas drawn> cards
    And it should be my Play Treasure phase
      And I should have 2 buys available

    Examples:
      | deck size | discard size | bob deck | chas deck | bob discard | chas discard | drawn | bob drawn | chas drawn |
      |     6     |       0      |    3     |     4     |     0       |       0      |   4   |     1     |     1      |
      |     2     |       4      |    3     |     4     |     0       |       0      |   4   |     1     |     1      |
      |     2     |       1      |    3     |     4     |     0       |       0      |   3   |     1     |     1      |
      |     0     |       0      |    3     |     4     |     0       |       0      |   0   |     1     |     1      |
      |     6     |       0      |    0     |     0     |     0       |       2      |   4   |     0     |     1      |
