Feature: Royal Seal
  2 Cash. While this is in play, when you gain a card, you may put that card on top of your deck.

  Background:
    Given I am a player in a standard game with Royal Seal

  Scenario: Royal Seal should be set up at game start
    Then there should be 10 Royal Seal cards in piles
      And there should be 0 Royal Seal cards not in piles

  Scenario: Royal Seal
    Given my hand contains Market, Market, Royal Seal, Gold
      And it is my Play Action phase
      And my deck contains Duchy x10
    When I play Market
    Then I should have drawn 1 card
    When I play Market
    Then I should have drawn 1 card
    When I stop playing actions
      And the game checks actions
    Then I should have played Royal Seal, Gold
      And it should be my Buy phase
    When I buy Silver
      And the game checks actions
    Then I should need to Choose whether to place Silver on top of deck
    When I choose the option On deck
    Then I should have put Silver on top of my deck
      And I should need to Buy
    When I buy Estate
      And the game checks actions
    Then I should need to Choose whether to place Estate on top of deck
    When I choose the option Discard
    Then I should have gained Estate
      And it should be my Buy phase