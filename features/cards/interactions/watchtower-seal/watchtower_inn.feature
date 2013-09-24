Feature: Watchtower + Inn
  Watchtower should apply before Inn's trigger; that is, you can move Inn onto your deck and not have it available to return

  Background:
    Given I am a player in a standard game with Inn

  Scenario: Watchtower delays choice
    Given my hand contains Woodcutter, Watchtower, Gold
      And I have Smithy in my discard
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Gold
    When I buy Inn
    And the game checks actions
      Then I should need to Decide on destination for Inn
      And I should not need to Shuffle discarded actions into deck
    When I choose the option Yes - Inn on deck
      Then I should have put Inn on top of my deck
    When the game checks actions
      Then I should need to Shuffle discarded actions into deck
      And I should have seen Smithy
    When I choose my peeked Smithy
      Then the following 2 steps should happen at once
        Then I should have moved Smithy from discard to deck
        And I should have shuffled my deck
      And I should need to Buy

  Scenario: Watchtower applied to Inn gives nothing to return
    Given my hand contains Woodcutter, Watchtower, Gold
      And I have nothing in discard
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Gold
    When I buy Inn
    And the game checks actions
      Then I should need to Decide on destination for Inn
      And I should not need to Shuffle discarded actions into deck
    When I choose the option Yes - Inn on deck
      Then I should have put Inn on top of my deck
    When the game checks actions
      Then I should have shuffled my deck
      And I should need to Buy