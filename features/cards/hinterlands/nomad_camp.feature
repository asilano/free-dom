Feature: Nomad Camp
  +1 Buy, +2 Cash.
  When you gain this, put it on top of your deck

  Background:
    Given I am a player in a standard game with Nomad Camp

  Scenario: Nomad Camp should be set up at game start
    Then there should be 10 Nomad Camp cards in piles
      And there should be 0 Nomad Camp cards not in piles
      And the Nomad Camp pile should cost 4

  Scenario: Playing Nomad Camp
    Given my hand contains Nomad Camp and 4 other cards
      And it is my Play Action phase
    When I play Nomad Camp
    Then I should have 2 buys available
      And I should have 2 cash
      And it should be my Play Treasure phase

  Scenario: Buying Nomad Camp
    Given my hand contains Woodcutter, Silver
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Silver
      And I should need to Buy
    When I buy Nomad Camp
    And the game checks actions
      Then I should have put Nomad Camp on top of my deck
      And I should need to Buy

  Scenario: Gaining Nomad Camp not via Buy
    Given my hand contains Remodel x2
      And Bob's hand contains Smuggler
      And it is my Play Action phase
    When I play Remodel
    And the game checks actions
      Then I should have removed Remodel from my hand
      And I should need to Take a replacement card with Remodel
    When I choose the Nomad Camp pile
    And the game checks actions
      Then I should have put Nomad Camp on top of my deck
      And it should be my Buy phase
    When Bob's next turn starts
      Then it should be Bob's Play Action phase
    When Bob plays Smuggler
    And the game checks actions
      Then Bob should have put Nomad Camp on top of his deck
      And it should be Bob's Buy phase