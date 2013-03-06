Feature: Peddler's cost and gain effects
  Peddler should be gained at full cost during the Action phase
  but at reduced cost during the Buy phase (including on last buy)

  Background:
    Given I am a player in a standard game with Peddler, Border Village

	 Scenario: Buying Border Village on first buy when Peddler costs 4
	   Given my hand contains Market x2, Silver x2
      And my deck contains Estate x5
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Market
      Then I should have drawn a card
    When I stop playing actions
      And the game checks actions
    Then I should have played Silver x2
      And I should have 6 cash available
      And I should need to Buy
      And the Border Village pile should cost 6
      And the Peddler pile should cost 4
    When I buy Border Village
      And the game checks actions
    Then I should have gained Border Village
      And I should need to Choose a card to gain with Border Village
      And the Peddler pile should cost 4
      And I should be able to choose the Copper, Curse, Estate, Silver, Smithy, Quarry, Duchy, Peddler piles
      And I should not be able to choose the Gold, Province piles
    When I choose the Peddler pile
      And the game checks actions
    Then I should have gained Peddler
      And I should need to Buy

	 Scenario: Buying Border Village on last buy when Peddler costs 4
	   Given my hand contains Village x2, Gold x2
      And my deck contains Estate x5
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Village
      Then I should have drawn a card
    When I stop playing actions
      And the game checks actions
    Then I should have played Gold x2
      And I should have 6 cash available
      And I should need to Buy
      And the Border Village pile should cost 6
      And the Peddler pile should cost 4
    When I buy Border Village
      And the game checks actions
    Then I should have gained Border Village
      And I should need to Choose a card to gain with Border Village
      And the Peddler pile should cost 4
      And I should be able to choose the Copper, Curse, Estate, Silver, Smithy, Quarry, Duchy, Peddler piles
      And I should not be able to choose the Gold, Province piles
    When I choose the Peddler pile
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Peddler
      And I should have ended my turn
    And it should be Bob's Play Action phase
