Feature: Scheme
  Draw 1 card, +1 Action. At the start of Clean-up this turn, you may choose an Action card you have in play.
  If you discard it from play this turn, put it on your deck.

  Background:
    Given I am a player in a standard game with Scheme
      And I have setting autoscheme off

  Scenario: Scheme should be set up at game start
    Then there should be 10 Scheme cards in piles
    And there should be 0 Scheme cards not in piles
    And the Scheme pile should cost 3

  Scenario: Playing Scheme - choice of cards
    Given my hand contains Scheme, Market, Throne Room
      And my deck contains Gold x10
      And it is my Play Action phase
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Throne Room
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Market from hand to play
        And I should have drawn 2 cards
      And I should have 2 actions available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x3 as treasure
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Market, Throne Room in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Market in play
      Then I should have moved Market from play to deck
    When the game checks actions
      Then I should have ended my turn
      And I should have Market, Gold x4 in my hand

  Scenario: Playing Scheme - choice of cards, choosing nothing
    Given my hand contains Scheme, Market, Throne Room
      And my deck contains Gold x10
      And it is my Play Action phase
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Throne Room
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Market from hand to play
        And I should have drawn 2 cards
      And I should have 2 actions available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x3 as treasure
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Market, Throne Room in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Choose nothing in play
      Then nothing should have happened
    When the game checks actions
      Then I should have ended my turn
      And I should have Gold x5 in my hand

  Scenario: Playing Scheme - one non-scheme card
    Given my hand contains Scheme, Market
      And my deck contains Gold x10
      And it is my Play Action phase
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Market
      Then I should have drawn 1 card
      And I should have 1 action available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x2 as treasure
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Market in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Market in play
      Then I should have moved Market from play to deck
    When the game checks actions
      Then I should have ended my turn
      And I should have Market, Gold x4 in my hand

  Scenario: Playing Scheme - only Scheme available
    Given my hand contains Scheme
      And my deck contains Gold x10
      And it is my Play Action phase
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold as treasure
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Scheme in play
      Then I should have moved Scheme from play to deck
    When the game checks actions
      Then I should have ended my turn
      And I should have Scheme, Gold x4 in my hand

  Scenario: Multiple Schemes, choice of cards
    Given my hand contains Scheme x2, Market, Throne Room
      And my deck contains Gold x10
      And it is my Play Action phase
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Throne Room
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Market from hand to play
        And I should have drawn 2 cards
      And I should have 2 actions available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x4 as treasure
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Market, Throne Room in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Market in play
      Then I should have moved Market from play to deck
    When the game checks actions
      And I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Throne Room in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Scheme in play
      Then I should have moved Scheme from play to deck
    When the game checks actions
      Then I should have ended my turn
      And I should have Market, Scheme, Gold x3 in my hand

  Scenario: AutoScheme with one Scheme
    Given my hand contains Scheme
      And my deck contains Gold x10
      And it is my Play Action phase
      And I have setting autoscheme on
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold as treasure
    When I stop buying cards
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Scheme from play to deck
        And I should have ended my turn
      And I should have Scheme, Gold x4 in my hand

  Scenario: AutoScheme with multiple Schemes
    Given my hand contains Scheme x2
      And my deck contains Gold x10
      And it is my Play Action phase
      And I have setting autoscheme on
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x2 as treasure
    When I stop buying cards
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Scheme x2 from play to deck
        And I should have ended my turn
      And I should have Scheme x2, Gold x3 in my hand

  Scenario: AutoScheme with multiple Schemes and another card
    Given my hand contains Scheme x3, Woodcutter
      And my deck contains Gold x10
      And it is my Play Action phase
      And I have setting autoscheme on
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Scheme
      Then I should have drawn 1 card
      And I should have 1 action available
    When I play Woodcutter
    And the game checks actions
      Then I should have played Gold x3 as treasure
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Woodcutter in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Scheme in play
      Then I should have moved Scheme from play to deck
    When the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Woodcutter in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Woodcutter in play
      Then I should have moved Woodcutter from play to deck
    When the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Scheme from play to deck
        And I should have ended my turn
      And I should have Scheme x2, Woodcutter, Gold x2 in my hand
