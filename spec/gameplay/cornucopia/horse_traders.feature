# Action-Reaction (cost: 4) - +1 Buy
# +$3
# Discard 2 cards.
# When another player plays an Attack card, you may first set this aside from your hand. If you do, then at the start of your next turn, +1 Card and return this to your hand.
Feature: Horse Traders
  Background:
    Given I am in a 2 player game
    And my hand contains Horse Traders, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Horse Traders
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Horse Traders
    When I choose Horse Traders in my hand
    Then I should have 2 buys
      And I should have $3
      And I should need to "Discard 2 cards"
    When I choose Gold, Village in my hand
    Then cards should move as follows:
      Then I should discard Gold, Village from my hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Horse Traders, only 1 card to discard
    Given my hand contains Horse Traders, Market
    When I choose Horse Traders in my hand
    Then I should have 2 buys
      And I should have $3
      And I should need to "Discard 1 card"
    When I choose Market in my hand
    Then cards should move as follows:
      Then I should discard Market from my hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"

  Scenario: Playing Horse Traders, nothing to discard
    Given my hand contains Horse Traders
    When I choose Horse Traders in my hand
    Then I should have 2 buys
      And I should have $3
    And I should need to "Play Treasures, or pass"

  Scenario: Holding Horse Traders lets a player react to attacks
    Given my hand contains Militia, Copper x4
      And Belle's hand contains Horse Traders, Copper, Silver, Estate, Duchy
    Then I should need to "Play an Action, or pass"
    When I choose Militia in my hand
    Then Belle should need to "React, or pass"
    When Belle chooses Horse Traders in her hand
    Then cards should move as follows:
      Then Belle should set aside Horse Traders from her hand
      And these card moves should happen
    And Belle should need to "Discard down by 1 card"
    When Belle chooses Estate in her hand
    Then cards should move as follows:
      Then Belle should discard Estate from her hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"
    When I pass through to just before Belle's next turn
      Then Belle should move Horse Traders from being set aside to her hand
      And Belle should draw 1 card
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"

  Scenario: A player holding two Horse Traders can react with both
    Given my hand contains Militia, Copper x4
      And Belle's hand contains Horse Traders x2, Silver, Estate, Duchy
    Then I should need to "Play an Action, or pass"
    When I choose Militia in my hand
    Then Belle should need to "React, or pass"
    When Belle chooses Horse Traders in her hand
    Then cards should move as follows:
      Then Belle should set aside Horse Traders from her hand
      And these card moves should happen
    And Belle should need to "React, or pass. (Already reacted with: Horse Traders)"
    When Belle chooses Horse Traders in her hand
    Then cards should move as follows:
      Then Belle should set aside Horse Traders from her hand
      And these card moves should happen
    And I should need to "Play Treasures, or pass"
    When I pass through to just before Belle's next turn
      Then Belle should move Horse Traders x2 from being set aside to her hand
      And Belle should draw 2 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"

  Scenario: A player holding Horse Traders doesn't have to react
    Given my hand contains Militia, Copper x4
      And Belle's hand contains Horse Traders, Copper, Silver, Estate, Duchy
    Then I should need to "Play an Action, or pass"
    When I choose Militia in my hand
    Then Belle should need to "React, or pass"
    When Belle chooses "Stop reacting" in her hand
    Then Belle should need to "Discard down by 2 cards"
