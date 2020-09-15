# Action/Reaction (cost: 2) - +2 Cards.
# When another player plays an Attack card, you may first reveal this from your hand, to be unaffected by it.
Feature: Moat
  Background:
    Given I am in a 3 player game

  Scenario: Playing Moat
    And my hand contains Moat, Estate, Copper, Silver
    And my deck contains Gold, Cellar, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Moat in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Holding Moat lets a player ignore an attack, no setting
    And my hand contains Militia, Copper x4
    And Belle's hand contains Moat, Copper x4
    And Chas's hand contains Copper x2, Silver x2
    Then I should need to 'Play an Action, or pass'
    When I choose Militia in my hand
    Then Belle should need to 'React, or pass'
    And Chas should need to 'Discard down by 1 card'
    When Belle chooses Moat in her hand
    Then Belle should need to 'React, or pass'
    When Belle chooses 'Stop reacting' in my hand
    Then Belle should not need to act

  Scenario: A player holding Moat doesn't have to use it
    And my hand contains Militia, Copper x4
    And Belle's hand contains Moat, Copper x4
    And Chas's hand contains Copper x2, Silver x2
    Then I should need to 'Play an Action, or pass'
    When I choose Militia in my hand
    Then Belle should need to 'React, or pass'
    And Chas should need to 'Discard down by 1 card'
    When Belle chooses 'Stop reacting' in her hand
    Then Belle should need to 'Discard down by 2 cards'

  Scenario: Holding Moat autoignores an attack, when set
    When pending
