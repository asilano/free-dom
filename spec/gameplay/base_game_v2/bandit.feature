# Action/Attack (cost: 5) - Gain a Gold. Each other player reveals the top 2 cards of their deck,
# trashes a revealed Treasure other than Copper, and discards the rest.
Feature: Bandit
  Background:
    Given I am in a 3 player game
    And my hand contains Bandit, Estate, Copper, Silver

  Scenario: Play Bandit normally (in series)
    When Belle's deck contains Gold, Silver
    And Chas's deck contains Gold, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Bandit in my hand
    Then cards should move as follows:
      Then I should gain Gold
      And these card moves should happen
    And Gold, Silver should be revealed on Belle's deck
    And Belle should need to 'Choose a treasure to trash'
    When Belle chooses Silver on her deck
    Then cards should move as follows:
      Then Belle should trash Silver from her deck
      And Belle should discard Gold from her deck
      And these card moves should happen
    And Gold, Silver should be revealed on Chas's deck
    And Chas should need to 'Choose a treasure to trash'
    When Chas chooses Gold on her deck
    Then cards should move as follows:
      And Chas should trash Gold from his deck
      And Chas should discard Silver from his deck
      And these card moves should happen

  Scenario: Play Bandit normally (in parallel)
    When Belle's deck contains Gold, Silver
    And Chas's deck contains Gold, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Bandit in my hand
    Then cards should move as follows:
      Then I should gain Gold
      And these card moves should happen
    And Gold, Silver should be revealed on Belle's deck
    And Belle should need to 'Choose a treasure to trash'
    And Gold, Silver should be revealed on Chas's deck
    And Chas should need to 'Choose a treasure to trash'
    When Chas chooses Gold on her deck
    Then cards should move as follows:
      And Chas should trash Gold from his deck
      And Chas should discard Silver from his deck
      And these card moves should happen
    When Belle chooses Silver on her deck
    Then cards should move as follows:
      Then Belle should trash Silver from her deck
      And Belle should discard Gold from her deck
      And these card moves should happen


  Scenario: Bandit hits nothing or Copper
    When Belle's deck contains Estate, Artisan
    And Chas's deck contains Copper, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Bandit in my hand
    Then cards should move as follows:
      Then I should gain Gold
      And Belle should discard Estate, Artisan from her deck
      And Chas should discard Copper, Village from his deck
      And these card moves should happen

  Scenario: Bandit hits empty deck
    When pending

  Scenario: Bandit results in no choices
    When pending
