Feature: Mint
  You may reveal a Treasure card from your hand. Gain a copy of it.
    When you buy this, trash all Treasures you have in play.

  Background:
    Given I am a player in a standard game with Mint, Talisman

  Scenario: Mint should be set up at game start
    Then there should be 10 Mint cards in piles
      And there should be 0 Mint cards not in piles

  Scenario: Playing Mint - multiple treasures in hand
    Given my hand contains Mint, Copper, Silver, Harem, Smithy
      And it is my Play Action phase
    When I play Mint
    Then I should need to Reveal a Treasure card from hand
      And I should be able to choose Copper, Silver, Harem in my hand
    When I choose Silver in my hand
      And the game checks actions
    Then I should have gained Silver
      And I should need to Play treasure

  Scenario: Playing Mint - one treasure in hand
    Given my hand contains Mint, Talisman x5, Smithy, Gardens
      And it is my Play Action phase
    When I play Mint
    Then I should need to Reveal a Treasure card from hand
      And I should be able to choose Talisman in my hand
    When I choose Talisman in my hand
      And the game checks actions
    Then I should have gained Talisman
      And I should need to Play treasure

  Scenario: Playing Mint - no treasures in hand
    Given my hand contains Mint, Smithy, Gardens, Nobles
      And it is my Play Action phase
    When I play Mint
    Then it should be my Play Treasure phase

  Scenario: Playing Mint - decline to copy
    Given my hand contains Mint, Smithy, Copper, Silver, Harem, Smithy
      And it is my Play Action phase
    When I play Mint
    Then I should need to Reveal a Treasure card from hand
      And I should be able to choose Copper, Silver, Harem in my hand
    When I choose Reveal nothing in my hand
    Then it should be my Play Treasure phase

  Scenario: Buying Mint - only treasures trashed, cash stays
    Given my hand contains Woodcutter, Harem, Copper, Silver, Bank
      And it is my Play Action phase
    When I play Woodcutter
    And the game checks actions
      Then I should need to Play Treasure
    When I play simple treasures
      Then I should have played Harem, Copper, Silver
    When the game checks actions
      And I should need to Play Treasure
    When I play Bank as treasure
    And the game checks actions
    Then it should be my Buy phase
      And I should have 11 cash
      And I should have 2 buys available
    When I buy Mint
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have removed Harem, Copper, Silver, Bank from play
        Then I should have gained Mint
    And it should be my Buy phase
      And I should have 6 cash

  Scenario: Mint doesn't hold up play if money's too tight
    Given my hand contains Copper
      And it is my Play Treasure phase
    When the game checks actions
      Then I should have played Copper
      And I should need to Buy

  Scenario: Mint doesn't hold up play if I have no treasures
    Given my hand contains Market x5
      And it is my Play Action phase
      And my deck is empty
    When I play Market
    And I play Market
    And I play Market
    And I play Market
    And I play Market
    And I stop playing actions
    And the game checks actions
      Then I should need to Buy
      And I should be able to choose the Mint pile