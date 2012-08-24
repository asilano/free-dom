Feature: Hoard
  2 Cash. While this is in play, when you buy a Victory card, gain a Gold.
  
  Background:
    Given I am a player in a standard game with Hoard
    
  Scenario: Hoard should be set up at game start
    Then there should be 10 Hoard cards in piles
      And there should be 0 Hoard cards not in piles
      
  Scenario: Hoard, all aspects
    Given my hand contains Market, Market, Hoard, Gold
      And it is my Play Action phase
      And my deck contains Duchy x10
    When I play Market
    Then I should have drawn 1 card
    When I play Market
    Then I should have drawn 1 card
    When I stop playing actions
      And the game checks actions
    Then I should have played Hoard, Gold
      And it should be my Buy phase
    When I buy Copper
      And the game checks actions
    Then I should have gained Copper
      And it should be my Buy phase      
    When I buy Estate
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Gold
      And I should have gained Estate    
    And it should be my Buy phase
    When I buy Duchy
      And the game checks actions
    Then the following 5 steps should happen at once
      Then I should have gained Gold
      And I should have gained Duchy
      And I should have moved Gold, Hoard, Market x2 from play to discard
      And I should have discarded Duchy x2
      And I should have drawn 5 cards
    And it should be Bob's Play Action phase