# Action/Attack (cost: 4) - +2 Cash
# Each other player discards down to 3 cards in hand.
Feature: Militia
  Background:
    Given I am in a 3 player game
    And my hand contains Militia, Estate, Copper, Silver, Gold

  Scenario: Playing Militia grants cash
    Then I should need to 'Play an Action, or pass'
    When I choose Militia in my hand
    Then I should have 2 cash

  Scenario: Playing Militia forces discard
    When Belle's hand contains Estate, Duchy, Copper x2, Village
    And Chas's hand contains Province, Gold, Bandit, Estate
    Then I should need to 'Play an Action, or pass'
    When I choose Militia in my hand
    Then Belle should need to 'Discard 2 cards'
    And Chas should need to 'Discard 1 card'
    When Belle chooses Estate in her hand
    Then cards should move as follows:
      Then Belle should discard Estate from her hand
      And these card moves should happen
    And Belle should need to 'Discard 1 card'
    When Chas chooses Estate in his hand
    Then cards should move as follows:
      Then Chas should discard Estate from his hand
      And these card moves should happen
    When Belle chooses Copper in her hand
    Then cards should move as follows:
      Then Belle should discard Copper from her hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Militia skips players already <= 3
    When Belle's hand contains Estate, Duchy, Copper
    And Chas's hand contains Province
    Then I should need to 'Play an Action, or pass'
    When I choose Militia in my hand
    Then Belle should not need to act
    And Chas should not need to act
    And I should need to "Play Treasures, or pass"
