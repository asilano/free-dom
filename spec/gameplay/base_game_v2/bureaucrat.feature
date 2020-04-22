# Action/Attack (cost: 4) - Gain a Silver onto your deck.
# Each other player reveals a Victory card from their hand and puts it onto their deck (or reveals a hand with no Victory cards).
Feature: Bureaucrat
  Background:
    Given I am in a 3 player game
    And my hand contains Bureaucrat, Estate, Copper, Silver

  Scenario: Play Bureaucrat normally (in series)
    When Belle's hand contains Estate, Duchy, Copper, Village
    And Chas's hand contains Province, Gold, Bandit, Estate
    Then I should need to 'Play an Action, or pass'
    When I choose Bureaucrat in my hand
    Then cards should move as follows:
      Then I should gain Silver to my deck
      And these card moves should happen
    And Belle should need to 'Choose a victory to put on your deck'
    When Belle chooses Estate in her hand
    Then cards should move as follows:
      Then Belle should move Estate from her hand to her deck
      And these card moves should happen
    And Chas should need to 'Choose a victory to put on your deck'
    When Chas chooses Province in his hand
    Then cards should move as follows:
      Then Chas should move Province from his hand to his deck
      And these card moves should happen

  Scenario: Play Bureaucrat normally (in parallel)
    When pending

  Scenario: Bureaucrat hits empty hand
    When pending

  Scenario: Bureaucrat hits no Victories
    When pending

  Scenario: Bureaucrat results in no choices
    When pending

  Scenario: Bureaucrat when Silver empty
    When pending
