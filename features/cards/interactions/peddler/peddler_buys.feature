Feature: Peddler's cost and buy triggers
  Peddler should be at reduced cost during resolution of buy triggers

  Background:
    Given I am a player in a standard game with Farmland, Smithy, Peddler

  Scenario: Buying Farmland and upgrading into Peddler
    Given my hand contains Estate, Village, Woodcutter, Gold x2
      And my deck contains Duchy x9
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Woodcutter
      Then I should have 2 buys available
    When I stop playing actions
      And the game checks actions
    Then I should have played Gold x2
      And it should be my Buy phase
      And the Peddler pile should cost 4
    When I buy Farmland
      And the game checks actions
    Then I should need to Trash a card with Farmland 
    When I choose Estate in my hand
      Then I should have removed Estate from my hand
      And I should need to Take a replacement card with Farmland
      And I should be able to choose the Smithy, Peddler piles
    When I choose the Peddler pile
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Peddler
      And I should have gained Farmland
    And it should be my Buy phase

  Scenario: Buying Farmland and upgrading a Peddler from hand
    Given my hand contains Estate, Peddler, Market x2, Silver x2
      And my deck contains Duchy x9
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Market
      Then I should have drawn a card
      And I should have 3 buys available
    When I stop playing actions
      And the game checks actions
    Then I should have played Silver x2
      And it should be my Buy phase
      And the Peddler pile should cost 4
    When I buy Farmland
      And the game checks actions
    Then I should need to Trash a card with Farmland 
    When I choose Peddler in my hand
      Then I should have removed Peddler from my hand
      And I should need to Take a replacement card with Farmland
      And I should be able to choose the Gold, Farmland piles
    When I choose the Gold pile
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Gold
      And I should have gained Farmland
    And it should be my Buy phase
