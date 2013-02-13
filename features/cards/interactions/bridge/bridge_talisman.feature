Feature: Bridge + Talisman
  When buying a normally-5-cost after Bridge, with a Talisman, should gain a copy

  Scenario: Buy a Wharf after Bridge, with Talisman
    Given I am a player in a standard game with Wharf
      And my hand contains Bridge, Silver, Talisman
      And it is my Play Action phase
    Then the Wharf pile should cost 5
    When I play Bridge
      Then I should have 1 cash
      And I should have 2 buys available
    When the game checks actions
      Then I should have played Silver, Talisman
      And the Wharf pile should cost 4
    When I buy Wharf
    And the game checks actions
      Then I should have gained Wharf x2

  # Mint will trash Talisman, but both abilities should trigger and happen
  Scenario: Buy a Mint after Bridge, with Talisman
    Given I am a player in a standard game with Mint
      And my hand contains Bridge, Silver, Talisman
      And it is my Play Action phase
    Then the Mint pile should cost 5
    When I play Bridge
      Then I should have 1 cash
      And I should have 2 buys available
    When the game checks actions
    And I play simple treasures
      Then I should have played Silver, Talisman
      And the Mint pile should cost 4
    When I buy Mint
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Mint x2
        And I should have removed Silver, Talisman from play