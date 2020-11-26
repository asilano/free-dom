# Action (cost: 4) - You may play an Action card from your hand twice.
Feature: Throne Room
  Background:
    Given I am in a 3 player game

  Scenario: Doubling Smithy (draw 6)
    And my hand contains Throne Room, Smithy, Copper, Silver, Estate
    And my deck contains Gold, Cellar, Copper, Village, Bandit, Artisan
    Then I should need to 'Play an Action, or pass'
    When I choose Throne Room in my hand
    Then I should need to 'Choose an Action to play twice'
    When I choose Smithy in my hand
    Then cards should move as follows:
      Then I should move Smithy from my hand to in play
      And I should draw 6 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Doubling Laboratory (try to draw 4, gain 2 actions)
    And my hand contains Throne Room, Laboratory, Copper, Silver, Estate
    And my deck contains Gold, Cellar, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Throne Room in my hand
    Then I should need to 'Choose an Action to play twice'
    When I choose Laboratory in my hand
    Then cards should move as follows:
      Then I should move Laboratory from my hand to in play
      And I should draw 3 cards
      And these card moves should happen
    And I should have 2 actions
    And I should need to 'Play an Action, or pass'

  Scenario: Doubling Bureaucrat (attack happens twice)
    And my hand contains Throne Room, Bureaucrat, Copper, Silver, Estate
    And Belle's hand contains Estate, Duchy, Copper, Village
    And Chas's hand contains Province, Gold, Bandit, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Throne Room in my hand
    Then I should need to 'Choose an Action to play twice'
    When I choose Bureaucrat in my hand
    Then cards should move as follows:
      Then I should move Bureaucrat from my hand to in play
      And I should gain Silver to my deck
      And Chas should move Province from his hand to his deck
      And these card moves should happen
    And Belle should need to 'Choose a victory to put on your deck'
    And Chas should not need to act
    When Belle chooses Estate in her hand
    Then cards should move as follows:
      Then Belle should move Estate from her hand to her deck
      And I should gain Silver to my deck
      And Belle should move Duchy from her hand to her deck
      And these card moves should happen

  Scenario: Doubling Throne Room (choose two things to double)
    And my hand contains Throne Room, Throne Room, Smithy, Laboratory
    And my deck contains Gold, Cellar, Copper, Village, Bandit, Artisan, Curse, Library, Market
    Then I should need to 'Play an Action, or pass'
    When I choose Throne Room in my hand
    Then I should need to 'Choose an Action to play twice'
    When I choose Throne Room in my hand
    Then cards should move as follows:
      Then I should move Throne Room from my hand to in play
      And these card moves should happen
    And I should need to 'Choose an Action to play twice'
    When I choose Smithy in my hand
    Then cards should move as follows:
      Then I should move Smithy from my hand to in play
      And I should draw 6 cards
      And these card moves should happen
    And I should need to 'Choose an Action to play twice'
    When I choose Laboratory in my hand
    Then cards should move as follows:
      Then I should move Laboratory from my hand to in play
      And I should draw 3 cards
      And these card moves should happen
    And I should have 2 actions
    And I should need to 'Play an Action, or pass'

  Scenario: Doubling nothing, nothing available
    And my hand contains Throne Room, Copper, Estate
    Then I should need to 'Play an Action, or pass'
    When I choose Throne Room in my hand
    Then I should need to 'Choose an Action to play twice'
    When I choose 'Choose nothing' in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'

  Scenario: Doubling nothing, but holding an Action
    And my hand contains Throne Room, Copper, Estate, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Throne Room in my hand
    Then I should need to 'Choose an Action to play twice'
    When I choose 'Choose nothing' in my hand
    Then cards should not move
    And I should need to 'Play Treasures, or pass'

  Scenario: Doubling a duration, TR tracks
    Given pending Seaside
