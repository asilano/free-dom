# Action (cost: 3) - +2 Cards, +1 Action, return this to the Supply.
# When you gain this, gain another Experiment (that doesn't come with another).
Feature: Experiment
  Background:
    Given I am in a 3 player game
    And my hand contains Experiment, Workshop, Estate, Gold, Silver
    And the kingdom choice contains Experiment

  Scenario: Playing Experiment
    And my deck contains Gold, Cellar
    Then I should need to 'Play an Action, or pass'
    When I choose Experiment in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And I should return Experiment to the supply from in play
      And these card moves should happen
    And I should have 1 action

  Scenario: Playing Experiment, insufficient cards
    And my deck contains Gold
    Then I should need to 'Play an Action, or pass'
    When I choose Experiment in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And I should return Experiment to the supply from in play
      And these card moves should happen
    And I should have 1 action

  Scenario: Playing Experiment, no cards
    And my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Experiment in my hand
    Then cards should move as follows:
      And I should return Experiment to the supply from in play
      And these card moves should happen
    And I should have 1 action

  Scenario: Buying Experiment
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    And I should need to "Buy a card, or pass"
    When I choose Experiment in the supply
    Then cards should move as follows:
      Then I should gain Experiment, Experiment
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Gaining Experiment otherwise
    Then I should need to 'Play an Action, or pass'
    When I choose Workshop in my hand
    And I should need to 'Choose a card to gain'
    When I choose Experiment in the supply
    Then cards should move as follows:
      Then I should gain Experiment x2
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'


  Scenario: Gaining last Experiment
    When the Experiment pile contains Experiment
    Then I should need to "Play an Action, or pass"
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose Gold in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    And I should need to "Buy a card, or pass"
    When I choose Experiment in the supply
    Then cards should move as follows:
      Then I should gain Experiment
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

