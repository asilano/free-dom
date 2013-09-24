Feature: Scheme
  Check that a Throned Scheme allows the return of two cards
  King's Courted Scheme allows the return of three
  KC'd Scheme and no other actions must handle Scheme-with-no-targets

  Background:
    Given I am a player in a standard game

  Scenario: Throned Scheme returns two cards
    Given my hand contains Scheme, Market, Throne Room
      And my deck contains Gold x10
      And it is my Play Action phase
    When I play Throne Room
    And I choose Scheme in my hand
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have played Scheme
        And I should have drawn 2 cards
    When I play Market
      Then I should have drawn a card
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x3
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Market, Throne Room in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Market in play
      Then I should have moved Market from play to deck
    When the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Throne Room in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Throne Room in play
      Then I should have moved Throne Room from play to deck
    When the game checks actions
      Then I should have ended my turn
      And I should have Market, Throne Room, Gold x3 in my hand

  Scenario: Courted Scheme returns three cards. Automatic is handled
    Given my hand contains Scheme, Market, King's Court
      And my deck contains Gold x10
      And it is my Play Action phase
      And I have setting autoscheme on
    When I play King's Court
    And I choose Scheme in my hand
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have played Scheme
        And I should have drawn 3 cards
    When I play Market
      Then I should have drawn a card
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x4
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, Market, King's Court in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Market in play
      Then I should have moved Market from play to deck
    When the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, King's Court in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose King's Court in play
      Then I should have moved King's Court from play to deck
    When the game checks actions
      Then the following 2 steps should happen at once
        Then I should have moved Scheme from play to deck
        And I should have ended my turn
      And I should have Market, King's Court, Scheme, Gold x2 in my hand

  Scenario: Courted Scheme can handle only two cards to return
    Given my hand contains Scheme, King's Court
      And my deck contains Gold x10
      And it is my Play Action phase
      And I have setting autoscheme on
    When I play King's Court
    And I choose Scheme in my hand
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have played Scheme
        And I should have drawn 3 cards
    When I stop playing actions
    And the game checks actions
      Then I should have played Gold x3
    When I stop buying cards
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose Scheme, King's Court in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose Scheme in play
      Then I should have moved Scheme from play to deck
    When the game checks actions
      Then I should need to Choose an Action card to return with Scheme
      And I should be able to choose King's Court in play
      And I should not be able to choose Gold in play
      And I should be able to choose a nil action in play
    When I choose King's Court in play
      Then I should have moved King's Court from play to deck
    When the game checks actions
      Then I should have ended my turn
      And I should have King's Court, Scheme, Gold x3 in my hand