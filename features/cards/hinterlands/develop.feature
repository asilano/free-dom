Feature: Develop - Action: 3
  Trash a card from your hand. Gain a card costing exactly 1 more than it and a card costing exactly 1 less than it,
    in either order, putting them on top of your deck.

  Background: Game contains Estate
    Given I am a player in a standard game with Develop, Moat, Thief, Salvager, Smithy

  Scenario: Develop should be set up at game start
    Then there should be 10 Develop cards in piles
      And there should be 0 Develop cards not in piles
      And the Develop pile should cost 3

  Scenario: Playing Develop. Choices for trash and both gains.
    Given my hand contains Develop, Woodcutter, Estate
      And it is my Play Action phase
      And the Smithy pile is empty
    When I play Develop
      Then I should need to Trash a card with Develop
    When I choose Woodcutter in my hand
      Then I should have removed Woodcutter from my hand
      And I should need to Take first replacement card with Develop
      And I should be able to choose the Estate, Moat, Thief, Salvager piles
      And I should not be able to choose the Silver, Gold, Smithy piles
    When I choose the Moat pile
    And the game checks actions
      Then I should have put Moat on top of my deck
      And I should need to Take second replacement card with Develop
      And I should be able to choose the Thief, Salvager piles
      And I should not be able to choose the Estate, Moat, Silver, Gold, Smithy piles
    When I choose the Thief pile
    And the game checks actions
      Then I should have put Thief on top of my deck
      And it should be my Buy phase

  Scenario: Playing Develop. Only one option for trash and each gain
    Given my hand contains Develop, Woodcutter
      And the Estate pile is empty
      And the Salvager pile is empty
      And the Smithy pile is empty
      And it is my Play Action phase
    When I play Develop
      Then I should have removed Woodcutter from my hand
      And I should need to Take first replacement card with Develop
      And I should be able to choose the Moat, Thief piles
      And I should not be able to choose the Silver, Gold, Estate, Salvager, Smithy piles
    When I choose the Moat pile
    And the game checks actions
      Then I should have put Moat, Thief on top of my deck
      And it should be my Buy phase

  Scenario: No card costing 1 less, choice for 1 more
    Given my hand contains Develop, Woodcutter
      And the Estate pile is empty
      And the Moat pile is empty
      And it is my Play Action phase
    When I play Develop
      Then I should have removed Woodcutter from my hand
      And I should need to Take replacement card with Develop
      And I should be able to choose the Thief, Salvager, Smithy piles
      And I should not be able to choose the Silver, Gold, Moat, Estate piles
    When I choose the Thief pile
    And the game checks actions
      Then I should have put Thief on top of my deck
      And it should be my Buy phase

  Scenario: No card costing 1 less, only 1 card costing 1 more
    Given my hand contains Develop, Woodcutter
      And the Estate pile is empty
      And the Moat pile is empty
      And the Salvager pile is empty
      And the Smithy pile is empty
      And it is my Play Action phase
    When I play Develop
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have removed Woodcutter from my hand
        Then I should have put Thief on top of my deck
      And it should be my Buy phase

  Scenario: No cards costing 1 less or more
    Given my hand contains Develop, Woodcutter
      And the Estate pile is empty
      And the Moat pile is empty
      And the Salvager pile is empty
      And the Smithy pile is empty
      And the Thief pile is empty
      And it is my Play Action phase
    When I play Develop
     Then I should have removed Woodcutter from my hand
     And it should be my Play Treasure phase

  Scenario: Nothing to trash
    Given my hand contains Develop
      And it is my Play Action phase
    When I play Develop
      Then it should be my Play Treasure phase