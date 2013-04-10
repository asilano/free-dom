Feature: Silk Road
  Victory - Worth 1 point per 4 victory cards in your deck

  Scenario Outline: Silk Road should be set up at game start
    Given I am a player in a <num>-player standard game with Silk Road
      Then there should be <pile count> Silk Road cards in piles
      And there should be 0 Silk Road cards not in piles
      And the Silk Road pile should cost 4

    Examples:
      | num | pile count |
      |  2  |     8      |
      |  3  |    12      |
      |  4  |    12      |
      |  5  |    12      |
      |  6  |    12      |

  Scenario Outline: Silk Road should be worth points==(victories in any zone)/4
    Given I am a player in a standard game with Silk Road
      And my hand contains Silk Road, Estate x<hand>
      And my deck contains Nobles x<deck>, Harem x<deck>
      And I have Tunnel x<discard> in discard
      And I have Lighthouse x<enduring> as durations
    When the game ends
    Then my score should be <score>

    Examples:
     | hand | deck | discard | enduring | score |
     |   0  |  0   |    0    |     0    |   0   |
     |   2  |  0   |    0    |     0    |   2   |
     |   3  |  0   |    0    |     0    |   4   |
     |   3  |  1   |    0    |     0    |   8   |
     |   3  |  2   |    0    |     0    |  13   |
     |   4  |  2   |    1    |     0    |  16   |
     |   0  |  3   |    4    |     2    |  22   |

  Scenario: Silk Road should contribute to score from all zones
    Given I am a player in a standard game
      And my hand contains Silk Road, Duchy x2
      And my deck contains Silk Road
      And I have Silk Road in discard
      And I have Silk Road in play
    When the game ends
    Then my score should be 10

  Scenario Outline: Silk Road works off having just itself
    Given I am a player in a standard game
      And my hand contains Silk Road x<num>
      And my deck is empty
    When the game ends
      Then my score should be <score>

    Examples:
    | num | score |
    |  1  |   0   |
    |  3  |   0   |
    |  4  |   4   |
    |  5  |   5   |
    |  9  |  18   |
    | 12  |  36   |
