Feature: Bridge + Remodel
  Bridge's cost reduction applies to both halves of Remodel, but does allow 0->3 remodelling
  
  Background:
    Given I am a player in a standard game with Wharf
  
  Scenario: Remodel, not 0->3
    Given my hand contains Village, Bridge, Remodel, Silver
      And my deck contains Estate
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Bridge
    And I play Remodel
    And I have noted the last history
    And I choose Silver in my hand
      Then I should have removed Silver from my hand
      And later history should include "[I] trashed a Silver from hand (cost: 2)."
      And I should need to Take a replacement card
      And I should be able to choose the Wharf pile
    When I choose the Wharf pile
    And the game checks actions
      Then I should have gained Wharf

  Scenario: Remodel 0->3
    Given my hand contains Village, Bridge, Remodel, Copper
      And my deck contains Estate
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Bridge
    And I play Remodel
    And I have noted the last history
    And I choose Copper in my hand
      Then I should have removed Copper from my hand
      And later history should include "[I] trashed a Copper from hand (cost: 0)."
      And I should need to Take a replacement card
      And I should be able to choose the Silver pile
    When I choose the Silver pile
    And the game checks actions
      Then I should have gained Silver