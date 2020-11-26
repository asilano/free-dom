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
    When I choose <CopperChoice> for Copper, <EstateChoice> for Estate in my peeked cards
    Then cards should move as follows:
      Then I should <CopperAction> Copper from my deck
      And I should <EstateAction> Estate from my deck
      And these card moves should happen
    And I should need to 'Play an Action, or pass'
    Examples:
      | CopperChoice | EstateChoice | CopperAction | EstateAction |
      | Discard      | Discard      | discard      | discard      |
      | Discard      | Trash        | discard      | trash        |
      | Trash        | Discard      | trash        | discard      |
      | Trash        | Trash        | trash        | trash        |

  Scenario: Playing Sentry, keep one
    Given my deck contains Artisan, Copper, Estate
    Then I should need to 'Play an Action, or pass'
    When I choose Sentry in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Trash and/or discard cards on your deck'
    When I choose <CopperChoice> for Copper, <EstateChoice> for Estate in my peeked cards
    Then cards should move as follows:
      Then I should <MoveAction> <MovedCard> from my deck
      And these card moves should happen
    And I should need to 'Play an Action, or pass'
    Examples:
      | CopperChoice | EstateChoice | MoveAction | MovedCard |
      | Discard      | Keep         | discard    | Copper    |
      | Trash        | Keep         | trash      | Copper    |
      | Keep         | Discard      | discard    | Estate    |
      | Keep         | Trash        | trash      | Estate    |

  Scenario: Playing Sentry, keep both
    Given my deck contains Artisan, Copper, Estate
    Then I should need to 'Play an Action, or pass'
    When I choose Sentry in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Trash and/or discard cards on your deck'
    When I choose Keep for Copper, Keep for Estate in my peeked cards
    Then cards should not move
    And I should need to 'Reorder the cards on top of your deck'
    When I choose '1st (topmost)' for Estate, '2nd (bottommost)' for Copper in my peeked cards
    Then cards should not move
    And my deck should contain Estate, Copper

  Scenario: Playing Sentry, only reveal 1 card
    Given my deck contains Artisan, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Sentry in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have 1 action
    And I should need to 'Trash and/or discard cards on your deck'
    When I choose Keep for Copper in my peeked cards
    Then cards should not move
    And my deck should contain Copper

  Scenario: Playing Sentry, nothing to reveal
    Given my deck contains Artisan
    Then I should need to 'Play an Action, or pass'
    When I choose Sentry in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Sentry, can't draw
    Given my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Sentry in my hand
    Then cards should not move
    And I should need to 'Play an Action, or pass'
