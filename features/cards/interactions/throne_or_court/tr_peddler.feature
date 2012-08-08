Feature: Peddler
  Peddler's costs are reduced by the number of cards in play, not the number of actions played
  
  Background:
    Given I am a player in a standard game with Peddler
  
  Scenario: Throne Room'd action
    Given my hand contains Throne Room, Woodcutter
      And it is my Play Action phase
    When I play Throne Room
    And the game checks actions
      Then I should have played Woodcutter
      And it should be my Buy phase
      And the Peddler pile should cost 4
      
  Scenario: King's Courted action
    Given my hand contains King's Court, Woodcutter
      And it is my Play Action phase
    When I play King's Court
    And I choose Woodcutter in my hand
    And the game checks actions
      Then I should have played Woodcutter
      And it should be my Buy phase
      And the Peddler pile should cost 4