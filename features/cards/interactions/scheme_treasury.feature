Feature:
  Check the interaction between Scheme and Treasury.
  Treasury happens when it's actually discarded, so Scheme gets a look-in first

  Background:
    Given I am a player in a standard game

  Scenario: Scheme + 2x Treasury, autotreasury off
    Given my hand contains Scheme, Treasury x2
      And my deck contains Gold x10
      And it is my Play Action phase
      And I have setting autotreasury off
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Treasury
      Then I should have drawn 1 card
      And I should have 1 actions available
    When I play Treasury
      Then I should have drawn 1 card
      And I should have 1 actions available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x3 as treasure
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Treasury in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Treasury in play
      Then I should have moved Treasury from play to deck
    When the game checks actions
      Then I should have moved Scheme, Gold x3 from play to discard
      Then I should need to Choose where to place Treasury
    When I choose the option Top of deck
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Treasury from play to deck
        And I should have drawn 5 cards
      And I should have Treasury x2, Gold x3 in my hand

  Scenario: Scheme + 2x Treasury, autotreasury on
    Given my hand contains Scheme, Treasury x2
      And my deck contains Gold x10
      And it is my Play Action phase
      And I have setting autotreasury on
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Treasury
      Then I should have drawn 1 card
      And I should have 1 actions available
    When I play Treasury
      Then I should have drawn 1 card
      And I should have 1 actions available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x3 as treasure
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Treasury in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Treasury in play
      Then I should have moved Treasury from play to deck
    When the game checks actions
      Then the following 3 steps should happen at once
        Then I should have moved Scheme, Gold x3 from play to discard
        And I should have moved Treasury from play to deck
        And I should have drawn 5 cards
      And I should have Treasury x2, Gold x3 in my hand

