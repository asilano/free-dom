Feature: Tunnel
    2 VP
    When you discard this other than during a Clean-up phase, you may reveal it. If you do, gain a Gold.

  Scenario Outline: Tunnel should be set up at game start
    Given I am a player in a <num>-player standard game with Tunnel
    Then there should be <pile count> Tunnel cards in piles
      And there should be 0 Tunnel cards not in piles
      And the Tunnel pile should cost 3

    Examples:
      | num | pile count |
      |  2  |     8      |
      |  3  |    12      |
      |  4  |    12      |
      |  5  |    12      |
      |  6  |    12      |

  Scenario: Tunnel should be worth 2 points
    Given I am a player in a standard game
      And my hand is empty
      And my deck contains Tunnel
    When the game ends
    Then my score should be 2

  Scenario: Tunnel should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Tunnel
      And my deck contains Tunnel
      And I have Tunnel in discard
      And I have Tunnel in play
    When the game ends
    Then my score should be 8

  Scenario: Tunnel should give a Gold on discard, if chosen
    Given I am a player in a standard game
      And my hand contains Tunnel, Cellar, Estate, Estate
      And my deck contains Cellar, Tunnel, Tunnel, Estate x5
      And I have setting autotunnel set to ASK
    When I play Cellar
    And I choose Tunnel, Estate, Estate in my hand
      Then I should have discarded Tunnel, Estate, Estate
    When the game checks actions
      Then I should need to Choose whether to gain a Gold from Tunnel
    When I choose the option Gain a Gold
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Gold
        And I should have drawn 3 cards
    When I play Cellar
    And I choose Tunnel, Tunnel in my hand
      Then I should have discarded Tunnel, Tunnel
    When the game checks actions
      Then I should need to Choose whether to gain a Gold from Tunnel
    When I choose the option Gain a Gold
    And the game checks actions
      Then I should have gained Gold
      And I should need to Choose whether to gain a Gold from Tunnel
    When I choose the option Gain a Gold
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Gold
        And I should have drawn 2 cards

  Scenario: Tunnel should not give a Gold on discard, if not chosen
    Given I am a player in a standard game
      And my hand contains Tunnel, Cellar, Estate, Estate
      And my deck contains Cellar, Tunnel, Tunnel, Estate x5
      And I have setting autotunnel set to ASK
    When I play Cellar
    And I choose Tunnel, Estate, Estate in my hand
      Then I should have discarded Tunnel, Estate, Estate
    When the game checks actions
      Then I should need to Choose whether to gain a Gold from Tunnel
    When I choose the option Don't gain a Gold
    And the game checks actions
      Then I should have drawn 3 cards

  Scenario: Autotunnel on always
    Given I am a player in a standard game
      And my hand contains Tunnel, Cellar, Tunnel, Estate
      And I have setting autotunnel set to ALWAYS
    When I play Cellar
    And I choose Tunnel, Tunnel in my hand
      Then I should have discarded Tunnel, Tunnel
    When the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Gold x2
        And I should have drawn 2 cards

  Scenario: Autotunnel off always
    Given I am a player in a standard game
      And my hand contains Tunnel, Cellar, Tunnel, Estate
      And I have setting autotunnel set to NEVER
    When I play Cellar
    And I choose Tunnel, Tunnel in my hand
      Then I should have discarded Tunnel, Tunnel
    When the game checks actions
      Then I should have drawn 2 cards

  Scenario: Tunnel trips on enemy action
    Given I am a player in a standard game
      And my hand contains Militia
      And Bob's hand contains Tunnel, Estate x3
      And Charlie's hand is empty
    When I play Militia
    And the game checks actions
    And Bob chooses Tunnel in his hand
      Then Bob should have discarded Tunnel
    When the game checks actions
      Then Bob should have gained Gold
      And it should be my Buy phase

  Scenario: Tunnel trips on enemy Minion
    Given I am a player in a standard game
      And my hand contains Minion
      And Bob's hand contains Tunnel, Estate x4
      And Charlie's hand is empty
    When I play Minion
    And the game checks actions
    And I choose the option Cycle hands
    And the game checks actions
      Then the following 4 steps should happen at once
        Then Bob should have discarded Tunnel, Estate x4
        And I should have drawn 4 cards
        And Bob should have drawn 4 cards
        And Bob should have gained Gold
      And it should be my Play Action phase

  Scenario: Tunnel doesn't trip on gain or buy
    Given I am a player in a standard game with Tunnel
      And my hand contains Copper x3, Moat, Remodel
    When I play Remodel
    And I choose Moat in my hand
      Then I should have removed Moat from my hand
    And I choose the Tunnel pile
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Tunnel
        And I should have played Copper x3
    When I buy Tunnel
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have gained Tunnel
        And I should have moved Copper x3, Remodel from play to discard
        And I should have drawn 5 cards

  Scenario: Tunnel doesn't trip during clean-up
    Given I am a player in a standard game
      And my hand contains Tunnel
    When I stop playing actions
    And the game checks actions
    And I stop buying cards
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have discarded Tunnel
        And I should have drawn 5 cards