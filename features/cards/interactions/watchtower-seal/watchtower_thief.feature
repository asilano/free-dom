Feature: Watchtower-Thief interaction
  When holding a Watchtower, any treasure stolen by Thief should be available for watchtowering

  Background:
    Given I am a player in a standard game

  Scenario:
    Given my hand contains Watchtower, Thief
      And Bob's deck contains Gold, Duchy
      And Charlie's deck is empty
    When I play Thief
    And the game checks actions
    And I choose Trash and Take for Bob's revealed Gold
    And the game checks actions
      Then I should need to Decide on destination for Gold
    When I choose the option Yes - Gold on deck
      Then the following 2 steps should happen at once
        Then Bob should have removed Gold from his deck
        And I should have put Gold on top of my deck
    When the game checks actions
      Then Bob should have moved Duchy from his deck to discard
      And it should be my Buy phase