Feature: Outpost
  You only draw 3 cards (instead of 5) in this turn's Clean-up phase. Take an extra turn after this one. This can't cause you to take more than two consecutive turns.

  Background:
    Given I am a player in a standard game with Outpost

  Scenario: Outpost should be set up at game start
    Then there should be 10 Outpost cards in piles
      And there should be 0 Outpost cards not in piles

  Scenario: Playing Outpost 
    Given my hand contains Outpost, Copper x2, Duchy x2
      And my deck contains 10 other cards
    When I play Outpost
      Then nothing should have happened
    When the game checks actions
      Then I should have played Copper x2
      And it should be my Buy phase
    When I stop buying cards
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have discarded Duchy x2
      And I should have moved Copper x2 from play to discard
      And I should have drawn 3 cards
      And I should have moved Outpost from enduring to play
    And it should be my Play Action phase
        
  Scenario: Playing Outpost on an Outpost turn - draw 3 cards, but no more turns
    Given my hand contains Outpost, Copper x2, Duchy x2
      And my deck contains Outpost, Gold, Colony, Copper x5
    When I play Outpost
      And the game checks actions
    Then I should have played Copper x2
      And it should be my Buy phase
    When I stop buying cards
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have discarded Duchy x2
      And I should have moved Copper x2 from play to discard
      And I should have drawn 3 cards
      And I should have moved Outpost from enduring to play
    And it should be my Play Action phase
    When I play Outpost
      And the game checks actions
    Then I should have played Gold
      And it should be my Buy phase
    When I stop buying cards
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have discarded Colony
      And I should have moved Gold, Outpost from play to discard
      And I should have drawn 3 cards
    And it should be Bob's Play Action phase
  
  Scenario: Playing Outpost with Throne Room
    Given my hand contains Outpost, Throne Room, Copper x2, Duchy
      And my deck contains Smithy x10
    When I play Throne Room
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have moved Throne Room from play to enduring
      And I should have played Outpost
      And I should have played Copper x2
    And it should be my Buy phase
    When I stop buying cards
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have discarded Duchy
      And I should have moved Copper x2 from play to discard
      And I should have drawn 3 cards
      And I should have moved Outpost, Throne Room from enduring to play
    And it should be my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then it should be my Buy phase
    When I stop buying cards
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have discarded Smithy x3
      And I should have moved Throne Room, Outpost from play to discard
      And I should have drawn 5 cards
    And it should be Bob's Play Action phase
  