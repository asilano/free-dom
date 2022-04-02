# Action-Attack (cost: 5) - +2 Coffers
# Each other player with 5 or more cards in hand discards one costing $2 or more (or reveals they can't).
Feature: Villain
  Background:
    Given I am in a 4 player game
    And my hand contains Villain, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Villain
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Villain - hit, miss and too small
    Given Belle's hand contains Copper, Estate, Village, Remodel, Gold
    And Chas's hand contains Copper x3, Curse x3
    And Donna's hand contains Estate, Village, Remodel, Gold
    When I choose Villain in my hand
    Then I should have 2 Coffers
    And I should not need to act
    And Belle should need to "Discard a card costing $2 or more"
    And Chas should not need to act
    And Donna should not need to act
    And Belle should be able to choose Estate, Village, Remodel, Gold in her hand
    And Belle should not be able to choose Copper in her hand
    And Belle should not be able to choose nothing in her hand
    When Belle chooses Estate in her hand
    Then cards should move as follows:
      Then Belle should discard Estate from her hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"
