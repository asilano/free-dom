Feature: Watchtower + Farmland

  # All 4-cost or 6-cost so that Watchtower->Duchy upgrade is automatic
  Background:
    Given I am a player in a standard game with Farmland, Feast, Smithy, Militia, Thief, Spy, Gardens, Moneylender, Remodel, Throne Room

  Scenario: Buy Farmland with Watchtower
    # The Watchtower should be able to apply to both gained cards, with the
    # upgraded card below the Farmland itself.

    Given my hand contains Woodcutter, Platinum x2, Watchtower x2, Estate
      And my deck is empty
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Platinum x2
      And it should be my Buy phase
      And I should have 12 cash available
      And I should have 2 buys available
      
    When I buy Farmland
    Then I should need to Trash a card with Farmland 
    When I choose Estate in my hand
    Then I should have removed Estate from my hand
      And I should need to Take a replacement card with Farmland
      And I should be able to choose the Smithy, Feast piles
      And I should not be able to choose the Copper, Curse, Estate, Silver, Duchy, Gold, Farmland, Province piles
    When I choose the Smithy pile
      And the game checks actions
    Then I should need to Decide on destination for Smithy
    When I choose the option Yes - Smithy on deck
    Then I should have put Smithy on top of my deck
    When the game checks actions
    Then I should need to Decide on destination for Farmland
    When I choose the option Yes - Farmland on deck
    Then I should have put Farmland on top of my deck
      And I should need to Buy
      
    When I buy Farmland expecting side-effects
    Then I should have removed Watchtower from my hand
    When the game checks actions
    Then I should need to Decide on destination for Duchy
    When I choose the option Yes - Duchy on deck
    Then I should have put Duchy on top of my deck
    When the game checks actions
    Then I should need to Decide on destination for Farmland
    When I choose the option Yes - Farmland on deck
    Then I should have put Farmland on top of my deck
      And my deck should contain Farmland, Duchy, Farmland, Smithy
