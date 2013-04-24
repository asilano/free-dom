Feature: Cache
  3 Cash. When you gain this, gain 2 Copper.

  Background:
    Given I am a player in a standard game with Cache

  Scenario: Cache should be set up at game start
    Then there should be 10 Cache cards in piles
      And there should be 0 Cache cards not in piles

  Scenario: Playing Cache
    Given my hand contains Cache
      And it is my Play Action phase
    When I stop playing actions
      And the game checks actions
    Then I should have played Cache
      And I should have 3 cash
      And it should be my Buy phase

  Scenario: Buying Cache
    Given my hand contains Woodcutter, Gold
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should have played Gold
    When I buy Cache
    And the game checks actions
      Then I should have gained Cache, Copper x2

  Scenario: Gaining Cache in non-buy means
    Given my hand contains Remodel x2
      And Bob's hand contains Smuggler
      And it is my Play Action phase
    When I play Remodel
    And the game checks actions
      Then I should have removed Remodel from my hand
      And I should need to Take a replacement card with Remodel
    When I choose the Cache pile
    And the game checks actions
      Then I should have gained Cache, Copper x2
      And it should be my Buy phase
    When Bob's next turn starts
      Then it should be Bob's Play Action phase
    When Bob plays Smuggler
      Then Bob should need to Take a card with Smuggler
      And Bob should be able to choose the Cache, Copper piles
    When Bob chooses the Cache pile
    And the game checks actions
      Then Bob should have gained Cache, Copper x2
      And it should be Bob's Buy phase
