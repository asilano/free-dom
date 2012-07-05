Feature: Mining Village
  Draw 1 card, +2 Actions. You may trash this card immediately; if you do, +2 cash.
    
  Background:
    Given I am a player in a standard game with Mining Village
  
  Scenario: Mining Village should be set up at game start
    Then there should be 10 Mining Village cards in piles
      And there should be 0 Mining Village cards not in piles
  
  Scenario: Playing Mining Village - no trash
    Given my hand contains Mining Village and 4 other cards
      And it is my Play Action phase
    When I play Mining Village
    Then I should have drawn 1 card
      And I should have 2 actions available
      And I should need to Optionally trash Mining Village
    When I choose the option Don't trash
    Then I should have 0 cash
      And it should be my Play Action phase
      
  Scenario: Playing Mining Village - trash
    Given my hand contains Mining Village and 4 other cards
      And it is my Play Action phase
    When I play Mining Village
    Then I should have drawn 1 card
      And I should have 2 actions available
      And I should need to Optionally trash Mining Village
    When I choose the option Trash
    Then I should have removed Mining Village from play
      And I should have 2 cash
      And it should be my Play Action phase
      
  Scenario: Playing multiple Mining Villages
    Given my hand contains Mining Village, Mining Village and 4 other cards
      And it is my Play Action phase
    When I play Mining Village
    Then I should have drawn 1 card
      And I should have 2 actions available
      And I should need to Optionally trash Mining Village
    When I choose the option Trash
    Then I should have removed Mining Village from play
      And I should have 2 cash
      And it should be my Play Action phase
    When I play Mining Village
    Then I should have drawn 1 card
      And I should have 3 actions available
      And I should need to Optionally trash Mining Village
    When I choose the option Trash
    Then I should have removed Mining Village from play
      And I should have 4 cash
      And it should be my Play Action phase