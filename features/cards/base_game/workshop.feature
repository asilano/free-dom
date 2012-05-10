Feature: Workshop
  Gain a card costing up to 4
  
  Background:
    Given I am a player in a standard game with Workshop, Cellar, Village, Bridge, Mine, Adventurer, Bank, Peddler
  
  Scenario: Workshop should be set up at game start
    Then there should be 10 Workshop cards in piles
      And there should be 0 Workshop cards not in piles
      
  Scenario: Playing Workshop
    Given my hand contains Workshop and 4 other cards
      And I have nothing in discard
      And the Village pile is empty
    When I play Workshop
    Then I should need to Take a card with Workshop
      And I should be able to choose the Estate, Copper, Silver, Cellar, Workshop, Bridge piles
      And I should not be able to choose the Duchym Province, Gold, Village, Adventurer, Bank, Mine, Peddler piles
    When I choose the Bridge pile
      And the game checks actions
    Then I should have gained Bridge
      # Spinning game actions will auto-play treasures and move to Buy
      And it should be my Buy phase
