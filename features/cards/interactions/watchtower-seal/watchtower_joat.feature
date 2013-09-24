Feature: Watchtower-Jack of all Trades
  Watchtower should apply to Jack's Silver gain before anything else happens
  So you should be able to put it on top and discard it (or not); and if
  you choose to trash it, you can end up with no top card at all.

  Background:
    Given I am a player in a standard game

  Scenario: Gain silver to top
    Given my hand contains Jack of all Trades, Estate, Watchtower
      And my deck contains Gold x3
      And it is my Play Action phase
    When I play Jack of all Trades
    And the game checks actions
      Then I should need to Decide on destination for Silver
    When I choose the option Yes - Silver on deck
      Then I should have put Silver on top of my deck
    When the game checks actions
      Then I should have seen Silver
    When I choose the option Don't discard Silver
    And the game checks actions
      Then I should have drawn 3 cards

  Scenario: Trash Silver, resulting in empty deck
    Given my hand contains Jack of all Trades, Estate, Watchtower
      And my deck is empty
      And it is my Play Action phase
    When I play Jack of all Trades
    And the game checks actions
      Then I should need to Decide on destination for Silver
    When I choose the option Yes - trash Silver
      Then nothing should have happened
    When the game checks actions
      Then I should have drawn 3 cards
