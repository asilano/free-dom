Feature: Crossroads - Action: 2
  Reveal your hand. Draw 1 card per Victory card revealed.
  If this is the first time you played a Crossroads this turn, +3 Actions.

  Background:
    Given I am a player in a standard game with Crossroads

  Scenario: Crossroads should be set up at game start
    Then there should be 10 Crossroads cards in piles
      And there should be 0 Crossroads cards not in piles
      And the Crossroads pile should cost 2

#  Scenario: Playing Shanty Town - no actions
#    Given my hand contains Shanty Town, Duchy x4
#      And it is my Play Action phase
#    When I play Shanty Town
#    Then I should have drawn 2 cards
#      And I should have 2 actions available
#      And it should be my Play Action phase

#  Scenario: Playing Shanty Town - actions
#    Given my hand contains Shanty Town, Smithy, Witch, Duchy x2
#      And it is my Play Action phase
#    When I play Shanty Town
#    Then I should have 2 actions available
#      And it should be my Play Action phase