Feature: Oasis
  Draw 1 card, +1 Action, +1 Cash. Discard a card

  Background:
    Given I am a player in a standard game with Oasis

  Scenario: Oasis should be set up at game start
    Then there should be 10 Oasis cards in piles
      And there should be 0 Oasis cards not in piles
      And the Oasis pile should cost 3

  Scenario: Playing Oasis
    Given my hand contains Oasis, Estate and 3 other cards
      And it is my Play Action phase
    When I play Oasis
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash
      And I should need to Discard a card with Oasis
    When I choose Estate in my hand
      Then I should have discarded Estate
      And it should be my Play Action phase

  Scenario: Playing multiple Oases
    Given my hand contains Oasis x2, Estate x2, Duchy
      And it is my Play Action phase
    When I play Oasis
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash
    When I choose Estate in my hand
      Then I should have discarded Estate
      And it should be my Play Action phase
    When I play Oasis
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 2 cash
    When I choose Duchy in my hand
      Then I should have discarded Duchy
      And it should be my Play Action phase

  Scenario: No choice for discard
    Given my hand contains Oasis, Estate
      And my deck contains Estate
      And it is my Play Action phase
    When I play Oasis
      Then the following 2 steps should happen at once
        Then I should have drawn 1 card
        And I should have discarded Estate
      And I should have 1 action available
      And I should have 1 cash
      And it should be my Play Action phase

  Scenario: Nothing to discard
    Given my hand contains Oasis
      And my deck is empty
      And it is my Play Action phase
    When I play Oasis
      Then I should have 1 action available
      And I should have 1 cash
      And it should be my Play Action phase