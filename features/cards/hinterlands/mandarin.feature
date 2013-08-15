Feature: Mandarin
  +3 Cash. Put a card from your hand on top of your deck. /
  When you gain this, put all Treasures you have in play on top of your deck in any order.

  Background:
    Given I am a player in a standard game with Mandarin, Border Village

  Scenario: Mandarin should be set up at game start
    Then there should be 10 Mandarin cards in piles
      And there should be 0 Mandarin cards not in piles

  Scenario: Playing Mandarin
    Given my hand contains Mandarin, Estate, Copper, Smithy
      And it is my Play Action phase
    When I play Mandarin
      Then I should have 3 cash
      And I should need to Put a card from hand onto deck
      And I should be able to choose Estate, Copper, Smithy in my hand
    When I choose Smithy in my hand
      Then I should have moved Smithy from hand to deck
      And it should be my Play Treasure phase

  Scenario: Playing Mandarin - one type of card in hand
    Given my hand contains Mandarin, Estate x2
      And it is my Play Action phase
    When I play Mandarin
      Then I should have moved Estate from hand to deck
      And I should have 3 cash
      And it should be my Play Treasure phase

  Scenario: Playing Mandarin - no cards in hand
    Given my hand contains Mandarin
      And it is my Play Action phase
    When I play Mandarin
      And I should have 3 cash
      And it should be my Play Treasure phase

  Scenario: Gaining Mandarin via Buy - place each. Cash remains
    Given my hand contains Woodcutter, Copper, Harem, Venture
      And my deck contains Silver
    When I play Woodcutter
    And the game checks actions
    And I play Venture as treasure
      Then I should have moved Silver from deck to play
    When the game checks actions
      Then I should need to Play treasure
    When I play simple treasures
      Then I should have played Copper, Harem
      And I should have 8 cash
    When the game checks actions
    And I buy Mandarin
    And the game checks actions
      Then I should have gained Mandarin
      And I should need to Put a treasure 4th from top with Mandarin
      And I should be able to choose Copper, Harem, Venture, Silver in play
      And I should be able to choose a nil action in play
      And I should not be able to choose Woodcutter in play
    When I choose Venture in play
      Then I should have moved Venture from play to deck
      And I should need to Put a treasure 3rd from top with Mandarin
      And I should be able to choose Copper, Harem, Silver in play
      And I should be able to choose a nil action in play
      And I should not be able to choose Woodcutter in play
    When I choose Copper in play
      Then I should have moved Copper from play to deck
      And I should need to Put a treasure 2nd from top with Mandarin
      And I should be able to choose Harem, Silver in play
      And I should be able to choose a nil action in play
      And I should not be able to choose Woodcutter in play
    When I choose Silver in play
      Then I should have moved Silver, Harem from play to deck
      And I should need to Buy

  Scenario: Gaining Mandarin during Buy, not as Buy. Place some, then bail.
    Given my hand contains Woodcutter, Copper x2, Harem, Venture
      And my deck contains Silver
    When I play Woodcutter
    And the game checks actions
    And I play Venture as treasure
      Then I should have moved Silver from deck to play
    When the game checks actions
    And I play simple treasures
      Then I should have played Copper x2, Harem
      And I should have 9 cash
    When the game checks actions
    And I buy Border Village
    And the game checks actions
      Then I should have gained Border Village
    When I choose the Mandarin pile
    And the game checks actions
      Then I should have gained Mandarin
      And I should need to Put a treasure 5th from top with Mandarin
      And I should be able to choose Copper, Harem, Venture, Silver in play
      And I should be able to choose a nil action in play
      And I should not be able to choose Woodcutter in play
    When I choose Venture in play
      Then I should have moved Venture from play to deck
      And I should need to Put a treasure 4th from top with Mandarin
      And I should be able to choose a nil action in play
      And I should be able to choose Copper, Harem, Silver in play
      And I should not be able to choose Woodcutter in play
    When I choose Copper in play
      Then I should have moved Copper from play to deck
      And I should need to Put a treasure 3rd from top with Mandarin
      And I should be able to choose Copper, Harem, Silver in play
      And I should be able to choose a nil action in play
      And I should not be able to choose Woodcutter in play
    When I choose Any order in play
      Then I should have moved Copper, Silver, Harem from play to deck
      And I should need to Buy

  Scenario: Buying Mandarin with one type of Treasure
    Given my hand contains Woodcutter, Gold x2
    When I play Woodcutter
    And the game checks actions
    And I play Gold as treasure
    And the game checks actions
    And I play Gold as treasure
    And the game checks actions
    When I buy Mandarin
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Mandarin
        And I should have moved Gold x2 from play to deck
      And I should need to Buy

  Scenario: Buying Mandarin with no Treasures
    Given my hand contains Market x5
      And my deck is empty
    When I play Market
    And I play Market
    And I play Market
    And I play Market
    And I play Market
    And I stop playing actions
    And the game checks actions
    And I buy Mandarin
    And the game checks actions
      Then I should have gained Mandarin
    And I should need to Buy

  Scenario: Mandarin doesn't hold up play if money's too tight
    Given my hand contains Copper
      And it is my Play Treasure phase
    When the game checks actions
      Then I should have played Copper
      And I should need to Buy