# Action (cost: 4) - +1 Action
# Each player may reveal a Province from their hand. If you do, discard it and gain any Prize (from
# the Prize pile) or a Duchy, onto your deck. If no-one else does, +1 Card and +$1.
Feature: Tournament
  Background:
    Given I am in a 3 player game
    And the kingdom choice contains Tournament

  Scenario: Playing Tournament - no-one reveals Province
    Given my hand contains Tournament
    And Belle's hand contains nothing
    And Chas's hand contains nothing
    Then I should need to "Play an Action, or pass"
    When I choose Tournament in my hand
    Then I should have 1 action
    Then I should need to "Reveal Province, or decline (Tournament player has not revealed a Province; no other player has revealed a Province)"
    And Belle should need to "Reveal Province, or decline (Tournament player has not revealed a Province; no other player has revealed a Province)"
    And Chas should need to "Reveal Province, or decline (Tournament player has not revealed a Province; no other player has revealed a Province)"
    When I choose "Reveal nothing" in my hand
    And Chas chooses "Reveal nothing" in his hand
    And Belle chooses "Reveal nothing" in her hand
    Then cards should move as follows:
      Then I should draw 1 card
      And these card moves should happen
    And I should have $1
    And I should need to "Play an Action, or pass"

  Scenario: Playing Tournament - player only reveals Province, gain one of full prize set
    Given pending

  Scenario: Playing Tournament - player only reveals Province, gain one of partial prize set, Duchy unavailable
    Given pending

  Scenario: Playing Tournament - player only reveals Province, choose Duchy with prizes available
    Given pending

  Scenario: Playing Tournament - player only reveals Province, only Duchy available
    Given pending

  Scenario: Playing Tournament - player only reveals Province, nothing available
    Given pending

  Scenario: Playing Tournament - only others reveal Province
    Given pending

  Scenario: Playing Tournament - everyone reveals Province
    Given pending

  Scenario: Playing Tournament - everyone can choose not to reveal Province
    Given pending
