# Project (cost: 6) - At the start of your turn, you may discard a Victory card for +2 Cards.
Feature: Crop Rotation
  Background:
    Given I am in a 3 player game
    And my hand contains Market, Cargo Ship, Gold, Village, Estate
    And the kingdom choice contains the Crop Rotation project

  Scenario: Crop Rotation triggers, discard a Victory
    Given my deck contains Copper x4, Estate, Gold x2
    And I have the Crop Rotation project
    Then I should need to "Play an Action, or pass"
    When I pass through to my next turn
    Then I should need to "Choose a Victory card to discard"
    And I should be able to choose Estate in my hand
    And I should be able to choose nothing in my hand
    And I should not be able to choose Copper in my hand
    When I choose Estate in my hand
    Then cards should move as follows:
      Then I should discard Estate from my hand
      And I should draw 2 cards
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: Crop Rotation triggers, decline to discard
    Given my deck contains Copper x4, Estate, Gold x2
    And I have the Crop Rotation project
    Then I should need to "Play an Action, or pass"
    When I pass through to my next turn
    Then I should need to "Choose a Victory card to discard"
    When I choose "Discard nothing" in my hand
    Then cards should not move
    And I should need to "Play an Action, or pass"

  Scenario: Crop Rotation triggers, no Victories in hand (auto-processes)
    Given my deck contains Copper x4, Village, Gold x2
    And I have the Crop Rotation project
    Then I should need to "Play an Action, or pass"
    When I pass through to my next turn
    Then I should need to "Play an Action, or pass"

  Scenario: When deck is too small, discarded card gets shuffled in
    Given my hand contains nothing
    And my deck contains Copper x4, Estate, Gold x1
    And I have the Crop Rotation project
    Then I should need to "Play an Action, or pass"
    When I pass through to my next turn
    Then I should need to "Choose a Victory card to discard"
    And I should be able to choose Estate in my hand
    And I should be able to choose nothing in my hand
    And I should not be able to choose Copper in my hand
    When I choose Estate in my hand
    Then cards should move as follows:
      Then I should discard Estate from my hand
      And I should draw 2 cards
      And these card moves should happen
    And I should need to "Play an Action, or pass"
    And my hand should contain Copper x4, Estate, Gold
