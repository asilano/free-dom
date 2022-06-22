# Action (cost: 3) - +2 Cash. Discard the top card of your deck. If it's an Action card, you may play it.
Feature: Vassal
  Background:
    Given I am in a 3 player game
    And my hand contains Vassal, Estate, Copper, Silver

  Scenario: Playing Vassal, hit non-action
    And my deck contains Gold, Cellar, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Vassal in my hand
    Then cards should move as follows:
      Then I should discard Gold from my deck
      And these card moves should happen
    And I should have $2
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Vassal, hit action, choose to play
    And my deck contains Smithy, Gold, Cellar, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Vassal in my hand
    Then cards should move as follows:
      Then I should discard Smithy from my deck
      And these card moves should happen
    And I should have $2
    And I should need to 'Choose to play Smithy'
    When I choose the option 'Play Smithy'
    Then cards should move as follows:
      Then I should move Smithy from my discard to in play
      And I should draw 3 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Vassal, hit action, choose not to play
    And my deck contains Smithy, Gold, Cellar, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Vassal in my hand
    Then cards should move as follows:
      Then I should discard Smithy from my deck
      And these card moves should happen
    And I should have $2
    And I should need to 'Choose to play Smithy'
    When I choose the option "Don't play"
    Then cards should not move
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Vassal, hit action granting actions, choose to play
    And my deck contains Village, Gold, Cellar, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Vassal in my hand
    Then cards should move as follows:
      Then I should discard Village from my deck
      And these card moves should happen
    And I should have $2
    And I should need to 'Choose to play Village'
    When I choose the option 'Play Village'
    Then cards should move as follows:
      Then I should move Village from my discard to in play
      And I should draw 1 card
      And these card moves should happen
    And I should have 2 actions
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Vassal, hit Throne Room, choose to play
    And my hand contains Vassal, Village, Copper, Silver
    And my deck contains Throne Room, Gold, Cellar, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Vassal in my hand
    Then cards should move as follows:
      Then I should discard Throne Room from my deck
      And these card moves should happen
    And I should have $2
    And I should need to 'Choose to play Throne Room'
    When I choose the option 'Play Throne Room'
    Then cards should move as follows:
      Then I should move Throne Room from my discard to in play
      And these card moves should happen
    Then I should need to 'Choose an Action to play twice'
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should move Village from my hand to in play
      And I should draw 2 cards
      And these card moves should happen
    And I should have 4 actions
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Vassal, hit nothing
    And my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Vassal in my hand
    Then cards should not move
    And I should have $2
    And I should need to 'Play Treasures, or pass'
