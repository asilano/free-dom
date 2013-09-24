Feature: Watchtower when multiple people are gaining
  One player's Watchtower shouldn't affect anyone else

  Background:
    Given I am a player in a standard game

  Scenario: One player has WT, the other doesn't
    Given my hand contains Ambassador, Estate, Copper
    And Charlie's hand contains Watchtower
      Then there should be 12 Estate cards in piles
    When I play Ambassador
    And I choose Estate in my hand
    And I choose Estate in my hand
      Then I should have removed Estate from my hand
      And there should be 13 Estate cards in piles
    When the game checks actions
      Then Bob should have gained Estate
      And there should be 12 Estate cards in piles
      And Charlie should need to Decide on destination for Estate
      And dump actions
    When Charlie chooses the option Yes - trash Estate
      Then dump actions
      Then nothing should have happened
      And there should be 11 Estate cards in piles