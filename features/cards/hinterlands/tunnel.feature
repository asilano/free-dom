Feature: Tunnel
    2 VP
    When you discard this other than during a Clean-up phase, you may reveal it. If you do, gain a Gold.

  Scenario Outline: Tunnel should be set up at game start
    Given I am a player in a <num>-player standard game with Tunnel
    Then there should be <pile count> Tunnel cards in piles
      And there should be 0 Tunnel cards not in piles

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
      Then I should need to Choose whether to gain a Gold
    When I choose the option Gain a Gold
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Gold
        And I should have drawn 3 cards
    When I play Cellar
    And I choose Tunnel, Tunnel in my hand
      Then I should have discarded Tunnel, Tunnel
    When the game checks actions
      Then I should need to Choose whether to gain a Gold
    When I choose the option Gain a Gold
    And the game checks actions
      Then I should have gained Gold
      And I should need to Choose whether to gain a Gold
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
      Then I should need to Choose whether to gain a Gold
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