# Action (cost: 5) - +1 Card. +1 Action. Look at the top 2 cards of your deck. Trash and/or discard any number of them. Put the rest back in any order.
Feature: Sentry
  Background:
    Given I am in a 3 player game
    And my hand contains Sentry, Estate, Copper x2, Silver

  Scenario Outline: Playing Sentry, keep neither
    Given my deck contains Artisan, Copper, Estate
    Then I should need to 'Play an Action, or pass'
    When I choose Sentry in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Trash and/or discard cards on your deck'
    When I choose <CopperChoice> for Copper, <SilverChoice> for Silver on my deck
    Then cards should move as follows:
      Then I should <CopperAction> Copper from my deck
      And I should <SilverAction> Silver from my deck
      And these card moves should happen
    And I should need to 'Play an Action, or pass'
    Examples:
      | CopperChoice | SilverChoice | CopperAction | SilverAction |
      | Discard      | Discard      | discard      | discard      |
      | Discard      | Trash        | discard      | trash        |
      | Trash        | Discard      | trash        | discard      |
      | Trash        | Trash        | trash        | trash        |

  Scenario: Playing Sentry, keep one
    Given pending

  Scenario: Playing Sentry, keep both
    Given pending

  Scenario: Playing Sentry, only reveal 1 card
    Given pending

  Scenario: Playing Sentry, nothing to reveal
    Given pending

  Scenario: Playing Sentry, can't draw
    Given pending
