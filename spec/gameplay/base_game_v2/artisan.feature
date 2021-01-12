# Action (cost: 6) - Gain a card to your hand costing up to 5. Put a card from your hand onto your deck.
Feature: Artisan
  Background:
    Given I am in a 3 player game
    And the kingdom choice contains Market, Workshop
    And my hand contains Artisan, Estate, Copper, Silver

  Scenario: Play Artisan normally
    Then I should need to 'Play an Action, or pass'
    When I choose Artisan in my hand
    Then I should need to 'Choose a card to gain into your hand'
    And I should be able to choose the Copper, Duchy, Workshop, Market piles
    And I should not be able to choose the Gold, Province piles
    When I choose Market in the supply
    Then cards should move as follows:
      Then I should gain Market to my hand
      And these card moves should happen
    And I should need to 'Choose a card to put onto your deck'
    When I choose Copper in my hand
    Then cards should move as follows:
      Then I should move Copper from my hand to my deck
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: No cards in hand to place
    Then I should need to 'Play an Action, or pass'
    When I choose Artisan in my hand
    Then I should need to 'Choose a card to gain into your hand'
    When I choose Market in the supply
      # Hack hand after gain
      And my hand contains nothing
    Then I should need to 'Choose a card to put onto your deck'
    When I choose 'Put nothing on deck' in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'
