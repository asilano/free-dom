Feature: Prince-Outpost
  Prince should trigger on Outpost turns too

  Background:
    Given I am a player in a standard game

  Scenario: Prince triggers on Outpost turns
    Given my hand contains Prince, Village, Smithy, Estate x2
      And my deck contains Outpost, Estate x5, Duchy x5
      And it is my Play Action phase
    When I play Prince
      Then I should need to Choose a card to set aside with Prince
      And I should be able to choose Village, Smithy in my hand
      And I should be able to choose a nil action named Leave Prince in play in my hand
      And I should not be able to choose a nil action named Set Prince aside alone in my hand
    When I choose Village in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Village from my hand
        And I should have removed Prince from play
      And it should be my Play Treasure phase
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have Village in play
        And I should have drawn a card
      And I should have 3 actions available
      And it should be my Play Action phase
    When I play Outpost
      Then it should be my Play Action phase
    When my turn is about to end
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Village from play
        And I should have discarded my in-play cards
        And I should have discarded my hand
        And I should have drawn 3 cards
      And I should need to Choose the first card to play at start of turn
    When I choose my peeked Outpost
      Then I should have moved Outpost from enduring to play
    When the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Village in play
        And I should have drawn a card
      And it should be my Play Action phase
      And I should have 3 actions available
