Feature: Ill-Gotten Gains
  When you play this, you may gain a Copper, putting it into your hand.
  When you gain this, each other player gains a Curse.

  Background:
    Given I am a player in a standard game with Ill-Gotten Gains, Mint

  Scenario: Ill-Gotten Gains should be set up at game start
    Then there should be 10 Ill-Gotten Gains cards in piles
      And there should be 0 Ill-Gotten Gains cards not in piles

  Scenario: Playing IGG - choose to gain / not to gain a Copper
    Given my hand contains Ill-Gotten Gains x2, Silver
      And it is my Play Action phase
    When I stop playing actions
    And the game checks actions
      Then it should be my Play Treasure phase
    When I play Ill-Gotten Gains as treasure
      Then I should have 1 cash
      And I should need to Choose whether to gain a Copper to hand
    When I choose the option Copper to hand
    And the game checks actions
      Then I should have placed Copper in my hand
      And I should need to Play Treasure
    When I play Ill-Gotten Gains as treasure
      Then I should have 2 cash
      And I should need to Choose whether to gain a Copper to hand
    When I choose the option Don't gain a Copper
    And the game checks actions
      Then I should need to Play Treasure

  Scenario: Playing IGG - auto gain a Copper
    Given my hand contains Ill-Gotten Gains, Gold
      And it is my Play Action phase
      And I have setting autoigg set to ALWAYS
    When I stop playing actions
    And the game checks actions
      Then it should be my Play Treasure phase
    When I play Ill-Gotten Gains as treasure
      Then I should have 1 cash
    When the game checks actions
      Then I should have placed Copper in my hand
      And I should need to Play Treasure

  Scenario: Playing IGG - auto don't gain a Copper
    Given my hand contains Ill-Gotten Gains
      And it is my Play Action phase
      And I have setting autoigg set to NEVER
    When I stop playing actions
    And the game checks actions
      Then it should be my Play Treasure phase
    When I play Ill-Gotten Gains as treasure
    And the game checks actions
      Then I should have 1 cash
      And I should need to Buy

  Scenario: Buying IGG
    Given my hand contains Woodcutter, Gold
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
    And I play Gold as treasure
    And the game checks actions
    And I buy Ill-Gotten Gains
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have gained Ill-Gotten Gains
        And Bob should have gained Curse
        And Charlie should have gained Curse

  Scenario: Gaining IGG in non-buy means
    Given my hand contains Remodel x2
      And Bob's hand contains Smuggler
      And it is my Play Action phase
    When I play Remodel
    And the game checks actions
      Then I should have removed Remodel from my hand
      And I should need to Take a replacement card with Remodel
    When I choose the Ill-Gotten Gains pile
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have gained Ill-Gotten Gains
        And Bob should have gained Curse
        And Charlie should have gained Curse
      And it should be my Buy phase
    When Bob's next turn starts
      Then it should be Bob's Play Action phase
    When Bob plays Smuggler
    And the game checks actions
      Then the following 3 steps should happen at once
        Then Bob should have gained Ill-Gotten Gains
        And I should have gained Curse
        And Charlie should have gained Curse
      And it should be Bob's Buy phase