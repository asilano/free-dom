# Action (cost: 5) - Draw until you have 7 cards in hand, skipping any Action cards you choose to; set those aside, discarding them afterwards.
Feature: Library
  Background:
    Given I am in a 3 player game

  Scenario: Playing Library, draw < 7 cards, all non-action
    And my hand contains Library, Estate x3
    And my deck contains Gold, Copper, Silver, Gardens, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 4 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Library, can't draw enough cards, all non-action
    And my hand contains Library, Estate x3
    And my deck contains Gold, Copper
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Library, draw 7 cards, all non-action
    And my hand contains Library
    And my deck contains Gold, Copper, Silver, Gardens, Estate, Duchy, Province
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 7 cards
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Library, draw < 7 cards, set aside one action
    And my hand contains Library, Estate x3
    And my deck contains Gold, Artisan, Silver, Gardens, Copper, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Artisan in my hand
    Then cards should move as follows:
      Then I should move Artisan from my hand to my library
      And I should draw 3 cards
      And I should move Artisan from my library to my discard
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Library, draw < 7 cards, varied action choices
    And my hand contains Library, Estate x3
    And my deck contains Gold, Artisan, Silver, Bandit, Copper, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Artisan in my hand
    Then cards should move as follows:
      Then I should move Artisan from my hand to my library
      And I should draw 2 cards
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Keep in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And I should move Artisan from my library to my discard
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Library, can't draw enough cards, varied action choices
    And my hand contains Library, Estate x3
    And my deck contains Gold, Artisan, Bandit, Silver
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Artisan in my hand
    Then cards should move as follows:
      Then I should move Artisan from my hand to my library
      And I should draw 1 card
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Keep in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And I should move Artisan from my library to my discard
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Library, draw 7 cards, varied action choices
    And my hand contains Library
    And my deck contains Gold, Artisan, Bandit, Silver, Village, Copper, Estate, Duchy
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Artisan in my hand
    Then cards should move as follows:
      Then I should move Artisan from my hand to my library
      And I should draw 1 card
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Keep in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Keep in my hand
    Then cards should move as follows:
      Then I should draw 3 card
      And I should move Artisan from my library to my discard
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario: Playing Library, set aside action, shuffle discards
    And my hand contains Library, Estate x3
    And my deck contains Gold, Artisan, Silver
    And my discard contains Gardens, Copper, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Artisan in my hand
    Then cards should move as follows:
      Then I should move Artisan from my hand to my library
      And I should draw 3 cards
      And I should move Artisan from my library to my discard
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'

  Scenario Outline: Playing Library, hybrid actions count
    And my hand contains Library, Estate x3
    And my deck contains Gold, Research, Silver, Gardens, Copper, Village
    Then I should need to 'Play an Action, or pass'
    When I choose Library in my hand
    Then cards should move as follows:
      Then I should draw 2 cards
      And these card moves should happen
    And I should need to 'Set aside or keep action'
    When I choose Research in my hand
    Then cards should move as follows:
      Then I should move Research from my hand to my library
      And I should draw 3 cards
      And I should move Research from my library to my discard
      And these card moves should happen
    And I should need to 'Play Treasures, or pass'
