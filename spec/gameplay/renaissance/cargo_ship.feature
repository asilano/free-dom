# Action-Duration (cost: 3) - +2 Cash. Once this turn, when you gain a card, you may set it aside face up (on this). At the start of your next turn, put it into your hand.

Feature: Cargo Ship
  Background:
    Given I am in a 3 player game
    And my hand contains Cargo Ship, Border Guard, Estate, Copper, Silver
    And my deck contains Gold x5
    And the kingdom choice contains Cargo Ship

    Scenario: Playing Cargo Ship for cash
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should have 2 cash
      And I should need to "Play Treasures, or pass"

    Scenario: Playing Cargo Ship, gaining one card, setting it aside
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should have 2 cash
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
        And I should discard Border Guard, Estate, Copper, Silver from my hand
        And I should draw 5 cards
        And these card moves should happen
      And Belle should need to "Play an Action, or pass"
      When Belle passes through to Chas's next turn
      Then Chas should need to "Play an Action, or pass"
      When Chas chooses "Leave Action Phase" in his hand
      Then Chas should need to "Play Treasures, or pass"
      When Chas chooses "Stop playing treasures" in his hand
      Then Chas should need to "Buy a card, or pass"
      When Chas chooses "Buy nothing" in the supply
      Then cards should move as follows:
        Then Chas should discard everything from his hand
        And Chas should discard everything from play
        And Chas should draw 5 cards
        And I should move Estate from being set aside to my hand
      And these card moves should happen
      Then I should need to "Play an Action, or pass"

    Scenario: Playing Cargo Ship, not gaining, it goes away
      Given pending

    Scenario: Playing Cargo Ship, gaining multiple cards, setting aside a later one
      Given pending

    Scenario: Playing Cargo Ship, gaining multiple cards, setting aside first unwatches
      Given pending

    Scenario: Playing two Cargo Ships, gaining one card, setting it aside once
      Given pending

    Scenario: Playing two Cargo Ships, gaining multiple cards, setting aside two
      Given pending

    Scenario: Multiplying Cargo Ship
      Given pending
