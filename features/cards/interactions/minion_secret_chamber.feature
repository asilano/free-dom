Feature: Minion + Secret Chamber
  Even with Minion played in nice mode, Secret Chamber should still be an option

  Background:
    Given I am a player in a standard game

  Scenario: Playing nice Minion - allow SC
    Given my hand contains Minion and 4 other cards
      And Bob's hand contains Secret Chamber
      And Bob's deck contains Copper x2
      And it is my Play Action phase
    When I play Minion
    And the game checks actions
      Then I should have 1 action available
      And Bob should need to React to Minion
    When Bob chooses Secret Chamber in his hand
      Then Bob should have drawn 2 cards
      And Bob should need to Place a card second-from-top of deck with Secret Chamber
    When Bob chooses Secret Chamber in his hand
      Then Bob should have moved Secret Chamber from hand to deck
      Then Bob should need to Place a card on top of deck with Secret Chamber
    When Bob chooses Copper in his hand
      Then Bob should have moved Copper from hand to deck
      And Bob should not need to act
      And I should need to Choose Minion mode
    When I choose the option +2 Cash
      Then I should have 2 cash
    When the game checks actions
      Then it should be my Play Action phase