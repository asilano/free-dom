Feature: Complex interactions with Durations

  Background:
    Given I am a player in a standard game

  Scenario: Ensure correct duration is tracked
      # TR a Lighthouse, then KC a Wharf. Check that the right effects are doubled/tripled next turn
    Given my hand contains Throne Room, King's Court, Lighthouse, Wharf
      And my deck contains Estate x20
      And it is my Play Action phase
    When I play Throne Room
    And I choose Lighthouse in my hand
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have played Lighthouse
        And I should have moved Throne Room from play to enduring 
      And I should have 2 cash
      And I should have 2 actions available
    When I play King's Court
    And I choose Wharf in my hand
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have played Wharf
        And I should have moved King's Court from play to enduring
        And I should have drawn 6 cards
      And I should have 4 buys available
    When my next turn starts
      Then the following 2 steps should happen at once
        Then I should have moved Throne Room, King's Court, Lighthouse, Wharf from enduring to play
        And I should have drawn 6 cards
      And I should have 2 cash
      And I should have 4 buys available
      And it should be my Play Action phase
      
  Scenario: KC->TR->[Lighthouse, Woodcutter, Smithy]
      # TR and Lighthouse should endure, the rest should be discarded
    Given my hand contains King's Court, Throne Room, Lighthouse, Woodcutter, Smithy
      And my deck contains Estate x20
      And it is my Play Action phase
    When I play King's Court
    And I choose Throne Room in my hand
    And the game checks actions
      Then I should have played Throne Room
    And I choose Woodcutter in my hand
    And the game checks actions      
      Then I should have played Woodcutter
      And I should have 4 cash
      And I should have 3 buys available
    When I choose Lighthouse in my hand
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have played Lighthouse
        And I should have moved Throne Room from play to enduring
        And I should have played Smithy
        And I should have drawn 6 cards
      And I should have 6 cash
    When my next turn starts
      Then I should have moved Throne Room, Lighthouse from enduring to play
      And I should have 2 cash
      And I should have 1 action available
      And I should have 1 buy available
      
  Scenario: KC->TR->[Lighthouse, Woodcutter, Wharf]
      # TR and Lighthouse should endure, the rest should be discarded
    Given my hand contains King's Court, Throne Room, Lighthouse, Woodcutter, Wharf
      And my deck contains Estate x20
      And it is my Play Action phase
    When I play King's Court
    And I choose Throne Room in my hand
    And the game checks actions
      Then I should have played Throne Room
    And I choose Woodcutter in my hand
    And the game checks actions      
      Then I should have played Woodcutter
      And I should have 4 cash
      And I should have 3 buys available
    When I choose Lighthouse in my hand
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have played Lighthouse
        And I should have moved Throne Room from play to enduring
        And I should have played Wharf
        And I should have drawn 4 cards
      And I should have 5 buys available
    When my next turn starts
      Then the following 2 steps should happen at once
        Then I should have moved Throne Room, Lighthouse, Wharf from enduring to play
        And I should have drawn 4 cards
      And I should have 2 cash
      And I should have 1 action available
      And I should have 3 buys available
