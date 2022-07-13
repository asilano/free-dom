# Action-Duration (cost: 3) - +2 Cash. Once this turn, when you gain a card, you may set it aside face up (on this). At the start of your next turn, put it into your hand.

Feature: Cargo Ship
  Background:
    Given I am in a 3 player game
    And my hand contains Cargo Ship, Border Guard, Estate, Copper, Silver
    And my deck contains Gold x10
    And the kingdom choice contains Cargo Ship, Gardens

    Scenario: Playing Cargo Ship for cash
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should have $2
      And I should need to "Play Treasures, or pass"

    Scenario: Playing Cargo Ship, gaining one card, setting it aside
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should have $2
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
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should have $2
      And I should need to "Play Treasures, or pass"
      When I choose "Stop playing treasures" in my hand
      Then I should need to "Buy a card, or pass"
      When I choose Estate in the supply
      Then cards should move as follows:
        Then I should gain Estate
        And these card moves should happen
      And I should need to "Choose whether to set aside Estate on Cargo Ship"
      When I choose the option "Don't set aside"
      Then cards should move as follows:
        And I should discard Border Guard, Estate, Copper, Silver from my hand
        And I should discard Cargo Ship from play
        And I should draw 5 cards
        And these card moves should happen

    Scenario: Playing Cargo Ship, gaining multiple cards, setting aside a later one
      When my hand contains Cargo Ship, Market, Estate, Copper, Silver
      Then I should need to 'Play an Action, or pass'
      When I choose Market in my hand
      Then cards should move as follows:
        Then I should draw 1 cards
        And these card moves should happen
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should need to "Play Treasures, or pass"
      When I choose "Stop playing treasures" in my hand
      Then I should need to "Buy a card, or pass"
      When I choose Estate in the supply
      Then cards should move as follows:
        Then I should gain Estate
        And these card moves should happen
      And I should need to "Choose whether to set aside Estate on Cargo Ship"
      When I choose the option "Don't set aside"
      Then I should need to "Buy a card, or pass"
      When I choose Copper in the supply
      Then cards should move as follows:
        Then I should gain Copper
        And these card moves should happen
      And I should need to "Choose whether to set aside Copper on Cargo Ship"
      When I choose the option "Set aside"
      Then cards should move as follows:
        Then I should set aside Copper from my discard on my Cargo Ship in play
        And I should discard everything from my hand
        And I should discard Market from play
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
        And I should move Copper from being set aside to my hand
      And these card moves should happen
      Then I should need to "Play an Action, or pass"

    Scenario: Playing Cargo Ship, gaining multiple cards, setting aside first unwatches
      When my hand contains Cargo Ship, Market, Estate, Copper, Silver
      Then I should need to 'Play an Action, or pass'
      When I choose Market in my hand
      Then cards should move as follows:
        Then I should draw 1 cards
        And these card moves should happen
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should need to "Play Treasures, or pass"
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
        And these card moves should happen
      Then I should need to "Buy a card, or pass"
      When I choose Copper in the supply
      Then cards should move as follows:
        Then I should gain Copper
        And I should discard everything from my hand
        And I should discard Market from play
        And I should draw 5 cards
        And these card moves should happen

    Scenario: Playing two Cargo Ships, gaining one card, setting it aside once
      When my hand contains Cargo Ship, Cargo Ship, Village, Market, Silver
      Then I should need to 'Play an Action, or pass'
      When I choose Village in my hand
      Then cards should move as follows:
        Then I should draw 1 cards
        And these card moves should happen
      Then I should need to 'Play an Action, or pass'
      When I choose Market in my hand
      Then cards should move as follows:
        Then I should draw 1 cards
        And these card moves should happen
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should need to "Play Treasures, or pass"
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
        And these card moves should happen
      Then I should need to "Buy a card, or pass"
      When I choose "Buy nothing" in the supply
      Then cards should move as follows:
        Then I should discard everything from my hand
        And I should discard Village, Market, Cargo Ship from play
        And I should draw 5 cards
        And these card moves should happen

    Scenario: Playing two Cargo Ships, gaining multiple cards, setting aside two
      When my hand contains Cargo Ship, Cargo Ship, Village, Market, Silver
      Then I should need to 'Play an Action, or pass'
      When I choose Village in my hand
      Then cards should move as follows:
        Then I should draw 1 cards
        And these card moves should happen
      Then I should need to 'Play an Action, or pass'
      When I choose Market in my hand
      Then cards should move as follows:
        Then I should draw 1 cards
        And these card moves should happen
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should need to "Play Treasures, or pass"
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
        And these card moves should happen
      Then I should need to "Buy a card, or pass"
      When I choose Silver in the supply
      Then cards should move as follows:
        Then I should gain Silver
        And these card moves should happen
      And I should need to "Choose whether to set aside Silver on Cargo Ship"
      When I choose the option "Set aside"
      Then cards should move as follows:
        Then I should set aside Silver from my discard on my Cargo Ship in play
        And I should discard everything from my hand
        And I should discard Village, Market from play
        And I should draw 5 cards
        And these card moves should happen

    Scenario: Multiplying Cargo Ship
      When my hand contains Throne Room, Cargo Ship, Village, Market, Silver
      Then I should need to 'Play an Action, or pass'
      When I choose Market in my hand
      Then cards should move as follows:
        Then I should draw 1 card
        And these card moves should happen
      Then I should need to 'Play an Action, or pass'
      When I choose Throne Room in my hand
      Then I should need to 'Choose an Action to play twice'
      When I choose Cargo Ship in my hand
      Then cards should move as follows:
        Then I should move Cargo Ship from my hand to in play
        And these card moves should happen
      Then I should need to "Play Treasures, or pass"
      When I choose "Stop playing treasures" in my hand
      Then I should need to "Buy a card, or pass"
      When I choose Silver in the supply
      Then cards should move as follows:
        Then I should gain Silver
        And these card moves should happen
      And I should need to "Choose whether to set aside Silver on Cargo Ship"
      When I choose the option "Set aside"
      Then cards should move as follows:
        Then I should set aside Silver from my discard on my Cargo Ship in play
        And these card moves should happen
      Then I should need to "Buy a card, or pass"
      When I choose Estate in the supply
      Then cards should move as follows:
        Then I should gain Estate
        And these card moves should happen
      And I should need to "Choose whether to set aside Estate on Cargo Ship"
      When I choose the option "Set aside"
      Then cards should move as follows:
        Then I should set aside Estate from my discard on my Cargo Ship in play
        And I should discard everything from my hand
        And I should discard Market from play
        And I should draw 5 cards
        And these card moves should happen
      And Belle should need to "Play an Action, or pass"
      When Belle passes through to just before my next turn
        Then I should move Estate, Silver from being set aside to my hand
        And these card moves should happen

    Scenario: An unused Cargo Ship doesn't trigger next turn
      Then I should need to 'Play an Action, or pass'
      When I choose Cargo Ship in my hand
      Then I should have $2
      And I should need to "Play Treasures, or pass"
      When I choose "Stop playing treasures" in my hand
      Then I should need to "Buy a card, or pass"
      When I choose Estate in the supply
      Then cards should move as follows:
        Then I should gain Estate
        And these card moves should happen
      And I should need to "Choose whether to set aside Estate on Cargo Ship"
      When I choose the option "Don't set aside"
      Then cards should move as follows:
        And I should discard Border Guard, Estate, Copper, Silver from my hand
        And I should discard Cargo Ship from play
        And I should draw 5 cards
        And these card moves should happen
      And Belle should need to "Play an Action, or pass"
      When Belle passes through to my next turn
      Then I should need to 'Play an Action, or pass'
      When I choose "Leave Action Phase" in my hand
      Then I should need to "Play Treasures, or pass"
      When I choose "Stop playing treasures" in my hand
      Then I should need to "Buy a card, or pass"
      When I choose Copper in the supply
      Then I should not need to act
      And cards should move as follows:
        Then I should gain Copper
        And I should discard everything from play
        And I should discard everything from my hand
        And I should draw 5 cards
        And these card moves should happen

    Scenario: An unused Cargo Ship can be Improved and still trigger
      Given my hand contains Cargo Ship, Improve, Village, Copper x2
      Then I should need to "Play an Action, or pass"
      When I choose Village in my hand
      Then cards should move as follows:
        Then I should draw 1 card
        And these card moves should happen
      Then I should need to "Play an Action, or pass"
      When I choose Cargo Ship in my hand
      Then I should need to "Play an Action, or pass"
      When I choose Improve in my hand
      Then I should need to "Play Treasures, or pass"
      When I choose "Stop playing treasures" in my hand
      Then I should need to "Buy a card, or pass"
      When I choose "Buy nothing" in the supply
      Then I should need to "Choose a card to Improve"
      When I choose Cargo Ship in play
      Then cards should move as follows:
        Then I should trash Cargo Ship from in play
        And these card moves should happen
      And I should need to "Choose a card to gain"
      When I choose Gardens in the supply
      Then cards should move as follows:
        Then I should gain Gardens
        And these card moves should happen
      And I should need to "Choose whether to set aside Gardens on Cargo Ship"
      When I choose the option "Set aside"
      Then cards should move as follows:
        Then I should set aside Gardens from my discard on the Cargo Ship in the trash
        And I should discard everything from my hand
        And I should discard everything from play
        And I should draw 5 cards
        And these card moves should happen
      And Belle should need to "Play an Action, or pass"
      When Belle passes through to just before my next turn
        Then I should move Gardens from being set aside to my hand
        And these card moves should happen
