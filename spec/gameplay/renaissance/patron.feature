# Action/Reaction (cost: 4) - +1 Villager, +2 Cash
# When something causes you to reveal this (using the word "reveal"), +1 Coffers.
Feature: Patron
  Background:
    Given I am in a 3 player game
    And my hand contains Patron, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Patron, Border Guard
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Patron
    When I choose Patron in my hand
    Then I should have $2
    And I should have 1 Villager

  # Requires Courtier, Ambassador or Gladiator
  Scenario: Reveal Patron, specifically, in own hand
    Given pending Courtier, Ambassador or Gladiator

  # Requires Shanty Town, Menagerie, Hunting Party, Crossroads,
  # Poor House, City Quarter, Royal Blacksmith, or Grand Castle
  Scenario: Reveal Patron as part of whole hand
    Given pending Shanty Town, Menagerie, Hunting Party, Crossroads, Poor House, City Quarter, Royal Blacksmith, or Grand Castle

  # Requires Scrying Pool, Golem, Loan, Venture, Farming Village, Sage,
  # Hunting Party, Rebuild, Journeyman, or Ghost
  Scenario: Reveal Patron as part of "reveal top of deck until"
    Given pending Scrying Pool, Golem, Loan, Venture, Farming Village, Sage, Hunting Party, Rebuild, Journeyman, or Ghost

  Scenario: Reveal Patron as part of "reveal top n of deck"
    Given my hand contains Border Guard
    And my deck contains Estate, Patron, Gold
    Then I should need to "Play an Action, or pass"
    When I choose Border Guard in my hand
    Then cards should move as follows:
      Then I should reveal 2 cards from my deck
      And these card moves should happen
    And I should have 1 Coffers

  # Requires Gladiator
  Scenario: Reveal specifically from hand as part of opponent's effect
    Given pending Gladiator

  Scenario: Reveal from hand for accountability as part of opponent's attack
    Given my hand contains Bureaucrat
    And Belle's hand contains Patron, Village, Gold
    And Chas's hand contains Estate
    Then I should need to "Play an Action, or pass"
    When I choose Bureaucrat in my hand
    Then cards should move as follows:
      Then I should gain Silver to my deck
      And Chas should move Estate from his hand to his deck
      And these card moves should happen
    And Belle should not need to act
    And Chas should not need to act
    And Belle should have 1 Coffers

  Scenario: Reveal from deck as part of opponent's attack
    Given my hand contains Bandit
    And Belle's deck contains Gold, Patron
    And Chas's deck contains Gold, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Bandit in my hand
    Then cards should move as follows:
      Then I should gain Gold
      And Belle should trash Gold from her deck
      And Belle should discard Patron from her deck
      And Chas should reveal 2 cards from his deck
      And these card moves should happen
    And Belle should have 1 Coffers

  # Requires Black Market
  Scenario: Reveal from Black Market stack
    Given pending Black Market

  # Requires Inn
  Scenario: Reveal specifically from discard
    Given pending Inn

  # Requires Bad Omens
  Scenario: Reveal from discard for accountability
    Given pending Bad Omens
