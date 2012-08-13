Feature: Bridge + Talisman
  When buying a normally-5-cost after Bridge, with a Talisman, should gain a copy
  
  Background:
    Given I am a player in a standard game with Wharf
    
  Scenario: Buy a Wharf after Bridge, with Talisman
    Given my hand contains Bridge, Silver, Talisman
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