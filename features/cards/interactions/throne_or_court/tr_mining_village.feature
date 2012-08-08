Feature: Throne Room + Mining Village
  TR into Goons, can only trash the MV once (after both have resolved)
    
  Background:
    Given I am a player in a standard game

  Scenario: Throne Room
    Given my hand contains Mining Village, Throne Room
      And it is my Play Action phase
    When I play Throne Room
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have played Mining Village
        And I should have drawn 2 cards
      And I should have 4 actions available
      And I should need to Optionally trash Mining Village
    When I choose the option Trash
      Then I should have removed Mining Village from play
      And I should have 2 cash      
      And it should be my Play Action phase
      And I should have 4 actions available
      
  Scenario: King's Court
    Given my hand contains Mining Village, King's Court
      And it is my Play Action phase
    When I play King's Court
    And I choose Mining Village in my hand
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have played Mining Village
        And I should have drawn 3 cards
      And I should have 6 actions available
      And I should need to Optionally trash Mining Village
    When I choose the option Trash
      Then I should have removed Mining Village from play
      And I should have 2 cash      
      And it should be my Play Action phase
      And I should have 6 actions available