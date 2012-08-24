Feature: Bridge + Bishop
  Bridge's cost reduction reduces the value of the Bishop's trash
  
  Background:
    Given I am a player in a standard game
  
  Scenario: Bishop trashes Bridged Estate - no bonus VP
    Given my hand contains Village, Bridge, Bishop, Estate
      And my deck contains Estate
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Bridge
    And I play Bishop
      Then I should have removed Estate from my hand
      And my score should be 1