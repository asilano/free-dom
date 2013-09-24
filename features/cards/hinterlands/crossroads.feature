Feature: Crossroads - Action: 2
  Reveal your hand. Draw 1 card per Victory card revealed.
  If this is the first time you played a Crossroads this turn, +3 Actions.

  Background:
    Given I am a player in a standard game with Crossroads

  Scenario: Crossroads should be set up at game start
    Then there should be 10 Crossroads cards in piles
      And there should be 0 Crossroads cards not in piles
      And the Crossroads pile should cost 2

  Scenario: Playing Crossroads - first, second and third times
    Given my hand contains Crossroads, Copper x2, Estate x2
      And my deck contains Great Hall, Crossroads, Harem, Duchy, Crossroads, Copper x5
      And it is my Play Action phase
    When I play Crossroads
      Then I should have drawn 2 cards
      And I should have 3 actions available
      And it should be my Play Action phase
    When I play Crossroads
      Then I should have drawn 3 cards
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play Crossroads
      Then I should have drawn 5 cards
      And I should have 1 action available
      And it should be my Play Action phase

  Scenario: Playing Crossroads - first Crossroads is second action
    Given my hand contains Village, Crossroads, Witch, Duchy x2
      And my deck contains Copper x5
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play Crossroads
      Then I should have drawn 2 cards
      And I should have 4 actions available
      And it should be my Play Action phase