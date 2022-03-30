# Action (cost: 5) - +3 Cards
# If your discard pile has any cards in it:
# +1 Coffers, then if you have at least 4 Coffers tokens, take the Treasure Chest.
#
# Treasure Chest (Artifact) - At the start of your Buy phase, gain a Gold.
Feature: Swashbuckler
  Background:
    Given I am in a 3 player game
    And my hand contains Swashbuckler, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Swashbuckler
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Swashbuckler, discard empty
    Given my discard contains nothing
    When I choose Swashbuckler in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
    And I should have 0 Coffers

  Scenario: Playing Swashbuckler, discard not empty
    Given my discard contains Curse
    When I choose Swashbuckler in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
    And I should have 1 Coffers

  Scenario: Playing Swashbuckler, discard gets shuffled
    Given my discard contains Curse
    And my deck contains Copper, Silver
    When I choose Swashbuckler in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
    And I should have 0 Coffers

  Scenario Outline: Playing Swashbuckler, Treasure Chest gain based on Coffers
    Given my discard contains Curse
    # Grant Villagers so that we don't leave Action Phase, which would trigger the Treasure Chest
    And I have 2 Villagers
    And I have <count> Coffers
    When I choose Swashbuckler in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And these card moves should happen
    And I should need to "Spend Villagers"
    And I should have <new_count> Coffers
    And I <should_gain_chest> have the Treasure Chest
    Examples:
      | count | new_count | should_gain_chest |
      | 0     | 1         | should not        |
      | 2     | 3         | should not        |
      | 3     | 4         | should            |
      | 5     | 6         | should            |

  Scenario: Treasure Chest acts at start of Buy
    Given I have the Treasure Chest
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then cards should move as follows:
      Then I should gain Gold
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Treasure Chest acts immediately after gainin
    Given my discard contains Curse
    And I have 3 Coffers
    When I choose Swashbuckler in my hand
    Then cards should move as follows:
      Then I should draw 3 cards
      And I should gain Gold
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Treasure Chest acts at start of each Buy
    Given pending - requires Cavalry or Villa
