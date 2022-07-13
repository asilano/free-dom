# Action (cost: 3) - +$2. At the start of Clean-up, you may trash an Action card you would
# discard from play this turn, to gain a card costing exactly $1 more than it.
Feature: Improve
  Background:
    Given I am in a 3 player game
    And my hand contains Improve, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Cellar, Improve, Gardens, Market, Moat, Chapel, Workshop, Witch, Village, Council Room

  Scenario: Playing Improve, upgrade Market
    Then I should need to 'Play an Action, or pass'
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should draw 1 cards
      And these card moves should happen
    And I should have $1
    And I should need to 'Play an Action, or pass'
    When I choose Improve in my hand
    Then I should have $3
    And I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then I should need to "Choose a card to Improve"
    When I choose Market in play
    Then cards should move as follows:
      Then I should trash Market from in play
      And these card moves should happen
    And I should need to "Choose a card to gain"
    Then I should be able to choose the Gold pile
    And I should not be able to choose the Cellar, Improve, Gardens, Market piles
    And I should not be able to choose nothing in the supply
    When I choose Gold in the supply
    Then cards should move as follows:
      Then I should gain Gold
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Playing Improve, upgrade Improve itself
    Then I should need to 'Play an Action, or pass'
    When I choose Improve in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then I should need to "Choose a card to Improve"
    When I choose Improve in play
    Then cards should move as follows:
      Then I should trash Improve from in play
      And these card moves should happen
    And I should need to "Choose a card to gain"
    When I choose Gardens in the supply
    Then cards should move as follows:
      Then I should gain Gardens
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Nothing available to take as replacement
    And the Gardens pile is empty
    Then I should need to 'Play an Action, or pass'
    When I choose Improve in my hand
    And I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then I should need to "Choose a card to Improve"
    When I choose Improve in play
    Then cards should move as follows:
      Then I should trash Improve from in play
      And these card moves should happen
  And I should need to "Choose a card to gain"
    When I choose "Gain nothing" in the supply
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Playing Improve, choose not to upgrade
    Then I should need to 'Play an Action, or pass'
    When I choose Improve in my hand
    And I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then I should need to "Choose a card to Improve"
    When I choose "Trash nothing" in play
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from play
      And I should draw 5 cards
      And these card moves should happen

  Scenario: Playing Improve, can only choose discarding Actions
    Then I should need to 'Play an Action, or pass'
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    Then I should need to 'Play an Action, or pass'
    When I choose Cargo Ship in my hand
    Then I should need to 'Play an Action, or pass'
    When I choose Improve in my hand
    And I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose Estate in the supply
    Then cards should move as follows:
      Then I should gain Estate
      And these card moves should happen
    And I should need to "Choose whether to set aside Estate on Cargo Ship"
    When I choose the option "Set aside"
    Then cards should move as follows:
      Then I should set aside Estate from my discard on my Cargo Ship in play
    Then I should need to "Choose a card to Improve"
    And I should be able to choose Improve, Village in play
    And I should not be able to choose Cargo Ship in play
      And these card moves should happen

  Scenario: Playing Improve, can choose Durations that aren't tracking
    Then I should need to 'Play an Action, or pass'
    When I choose Village in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    Then I should need to 'Play an Action, or pass'
    When I choose Cargo Ship in my hand
    Then I should need to 'Play an Action, or pass'
    When I choose Improve in my hand
    And I should need to "Play Treasures, or pass"
    When I choose "Stop playing treasures" in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then I should need to "Choose a card to Improve"
    And I should be able to choose Improve, Village, Cargo Ship in play
