Feature: Feast
  Trash this card. Gain a card costing up to 5
  
  Background:
    Given I am a player in a standard game with Feast, Cellar, Village, Bridge, Mine, Adventurer, Bank, Peddler
  
  Scenario: Feast should be set up at game start
    Then there should be 10 Feast cards in piles
      And there should be 0 Feast cards not in piles
      
  Scenario: Playing Feast
    Given my hand contains Feast and 4 other cards
      And I have nothing in discard
      And the Village pile is empty
    When I play Feast
    Then I should have removed Feast from play
      And I should need to Take a card with Feast
      And I should be able to choose the Estate, Duchy, Copper, Silver, Cellar, Feast, Bridge, Mine piles
      And I should not be able to choose the Province, Gold, Village, Adventurer, Bank, Peddler piles
    When I choose the Mine pile
      And the game checks actions
    Then I should have gained Mine
      # Spinning game actions will auto-play treasures and move to Buy
      And it should be my Buy phase