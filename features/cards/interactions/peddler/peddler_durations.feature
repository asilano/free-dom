Feature: Peddler's cost and Durations
  Peddler should be made cheaper both by durations in play (that is, having happened twice)
  and enduring (that is, having happened only once)

  Background:
    Given I am a player in a standard game with Peddler

  Scenario:
    Given my hand is empty
      And it is my Play Action phase
      And I have Lighthouse in play
      And I have Fishing Village as a duration
    When I stop playing actions
    And the game checks actions
      Then it should be my Buy phase
      And the Peddler pile should cost 4
