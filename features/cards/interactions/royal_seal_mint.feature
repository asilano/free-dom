Feature: Royal Seal + Mint
  
  Background:
    Given I am a player in a standard game with Mint
      
  Scenario: Spending cash from Royal Seal on a Mint
  # The Royal Seal should be trashed before it would modify the gain of Mint,
  # so you don't get to use Royal Seal to put the Mint on top of your deck

    Given my hand contains Woodcutter, Royal Seal, Gold
      And it is my Play Action phase
    When I play Woodcutter
      Then I should have 2 buys available
    When the game checks actions
      Then I should need to Play treasure
    When I play Royal Seal as treasure
      And I play Gold as treasure
    Then it should be my Buy phase
    And the following 2 steps should happen at once
      When I buy Mint
      Then I should have removed Royal Seal, Gold from my play
    When the game checks actions
      Then I should have gained Mint
      And I should have 2 cash available
