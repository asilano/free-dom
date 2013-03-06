Feature: Border Village $6
+1 Card, +2 Actions
When you gain this, gain a card costing less than this.

  Background:
    Given I am a player in a standard game with Border Village, Smithy, Quarry, Peddler, Adventurer, Harem, Nobles, Expand, Forge, King's Court

  Scenario: Border Village should be set up at game start
    Then there should be 10 Border Village cards in piles
      And there should be 0 Border Village cards not in piles
      And the Border Village pile should cost 6

  Scenario: Playing Border Village
    Given my hand contains Border Village x2
      And it is my Play Action phase
	    Then I should have 1 action available
    When I play Border Village
	    Then I should have drawn a card
	    And I should have 2 actions available
    When I play Border Village
	    Then I should have drawn a card
	    And I should have 3 actions available

  Scenario: Buying Border Village
	  Given my hand contains Woodcutter, Silver x2
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Silver x2
      And it should be my Buy phase
    When I buy Border Village
      And the game checks actions
    Then I should have gained Border Village
      And I should need to Choose a card to gain with Border Village
      And I should be able to choose the Copper, Curse, Estate, Silver, Smithy, Duchy piles
      And I should not be able to choose the Gold, Province piles
    When I choose the Duchy pile
      And the game checks actions
    Then I should have gained Duchy
      And I should need to Buy

  Scenario: Buying Border Village when Border Village's cost is changed by Quarry
	  Given my hand contains Woodcutter, Silver, Quarry
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Silver, Quarry
      And it should be my Buy phase
      And the Border Village pile should cost 4
      And the Smithy pile should cost 2
    When I buy Border Village
      And the game checks actions
    Then I should have gained Border Village
      And I should need to Choose a card to gain with Border Village
      And I should be able to choose the Copper, Curse, Estate, Silver, Smithy piles
      And I should not be able to choose the Quarry, Peddler, Duchy, Border Village, Gold, Province piles
    When I choose the Silver pile
      And the game checks actions
    Then I should have gained Silver
      And I should need to Buy

  Scenario: Buying Border Village when Border Village's cost is changed by two Quarries
	  Given my hand contains Woodcutter, Quarry x2
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Quarry x2
      And it should be my Buy phase
      And the Border Village pile should cost 2
      And the Smithy pile should cost 0
    When I buy Border Village
      And the game checks actions
    Then I should have gained Border Village
      And I should need to Choose a card to gain with Border Village
      And I should be able to choose the Copper, Curse, Smithy piles
      And I should not be able to choose the Estate, Silver, Quarry, Peddler, Duchy, Border Village, Gold, Province piles
    When I choose the Copper pile
      And the game checks actions
    Then I should have gained Copper
      And I should need to Buy
  
  Scenario: Gaining Border Village in non-buy means
    Given my hand contains Remodel x2
      And Bob's hand contains Smuggler
      And it is my Play Action phase
    When I play Remodel
      And the game checks actions
    Then I should have removed Remodel from my hand
      And I should need to Take a replacement card with Remodel
    When I choose the Border Village pile
      And the game checks actions
    Then I should have gained Border Village
      And I should need to Choose a card to gain with Border Village
      And I should be able to choose the Copper, Curse, Estate, Silver, Smithy, Duchy piles
      And I should not be able to choose the Gold, Province piles
    When I choose the Duchy pile
      And the game checks actions
    Then I should have gained Duchy
      And it should be my Buy phase
    When Bob's next turn starts
      Then it should be Bob's Play Action phase
    When Bob plays Smuggler
      Then Bob should need to Take a card with Smuggler
    When Bob chooses the Border Village pile
      And the game checks actions
    Then Bob should have gained Border Village
      And Bob should need to Choose a card to gain with Border Village
      And Bob should be able to choose the Copper, Curse, Estate, Silver, Smithy, Duchy piles
      And Bob should not be able to choose the Gold, Province piles
    When Bob chooses the Silver pile
      And the game checks actions
    Then Bob should have gained Silver
      And it should be Bob's Buy phase

  Scenario: Buying Border Village when only 1 choice available (!)
	  Given my hand contains Woodcutter, Quarry x2
      And the Curse, Estate, Smithy, Peddler piles are empty
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Quarry x2
      And it should be my Buy phase
    When I buy Border Village
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Border Village
      And I should have gained Copper
    And I should need to Buy

  Scenario: Buying Border Village when Border Village costs 0 (!)
	  Given my hand contains Border Village, King's Court x2, Bridge x2
	    And my deck contains Province
	    And it is my Play Action phase
	  When I play Border Village
	    Then I should have drawn 1 card
	  When I play King's Court
      Then I should need to Choose a card to play with King's Court
    When I choose Bridge in my hand
      And the game checks actions
    Then I should have played Bridge
	    And I should need to Play action
	  When I play King's Court
      Then I should need to Choose a card to play with King's Court
    When I choose Bridge in my hand
      And the game checks actions
    Then I should have played Bridge
	    And it should be my Buy phase
	    And the Border Village pile should cost 0
	  When I buy Border Village
	    And the game checks actions
	    Then I should have gained Border Village
	  And I should need to Buy