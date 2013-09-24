Feature: Farmland $6
2 VP 
When you buy this, trash a card from your hand. Gain a card costing exactly $2 more than the trashed card.

  Background:
    Given I am a player in a standard game with Farmland, Feast, Smithy, Militia
    
  Scenario Outline: Farmland should be set up at game start
    Given I am a player in a <num>-player standard game with Farmland
    Then there should be <pile count> Farmland cards in piles
      And there should be 0 Farmland cards not in piles
      
    Examples:
      | num | pile count | 
      |  2  |     8      |  
      |  3  |    12      |  
      |  4  |    12      | 
      |  5  |    12      |  
      |  6  |    12      | 
      
  Scenario: Farmland should be worth 2 points
    Given my hand is empty
      And my deck contains Farmland
    When the game ends
    Then my score should be 2
    
  Scenario: Farmland should contribute to score from all normal zones
    Given my hand contains Farmland
      And my deck contains Farmland
      And I have Farmland in discard
      And I have Farmland in play
    When the game ends
    Then my score should be 8 
 
 
  Scenario: Buying Farmland with multiple cards in hand and multiple upgrade choices 
    Given my hand contains Gold x2, Woodcutter, Moat, Estate
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Gold x2
      And it should be my Buy phase
      And I should have 8 cash available
    When I buy Farmland 
    Then I should need to Trash a card with Farmland 
    When I choose Estate in my hand
    Then I should have removed Estate from my hand
      And I should need to Take a replacement card with Farmland
      And I should be able to choose the Smithy, Militia, Feast piles
      And I should not be able to choose the Copper, Curse, Estate, Silver, Duchy, Gold, Province piles
    When I choose the Smithy pile
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Smithy
      And I should have gained Farmland
    And it should be my Buy phase
      And I should have 2 cash available
      
  
  Scenario: Buying Farmland with multiple cards in hand and precisely one upgrade choice 
    Given my hand contains Gold x2, Woodcutter, Adventurer, Moat, Duchy
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Gold x2
      And it should be my Buy phase
    When I buy Farmland
      And the game checks actions
    Then I should need to Trash a card with Farmland 
    When I choose Adventurer in my hand
    Then I should have removed Adventurer from my hand
    When the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Province
      And I should have gained Farmland
    And it should be my Buy phase
      And I should have 2 cash available
  
  
  Scenario: Buying Farmland with just one kind of card in hand and multiple upgrade choices 
    Given my hand contains Gold x2, Woodcutter, Moat x2
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Gold x2
      And it should be my Buy phase
    When I buy Farmland expecting side-effects
    Then I should have removed Moat from my hand
      And I should need to Take a replacement card with Farmland
      And I should be able to choose the Smithy, Militia, Feast piles
      And I should not be able to choose the Copper, Estate, Silver, Duchy, Gold, Province piles
    When I choose the Smithy pile
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have gained Smithy
      And I should have gained Farmland
    And it should be my Buy phase
      And I should have 2 cash available

  
  Scenario Outline: Buying Farmland with just one type of card in hand and precisely one upgrade choice
      
    Given my hand contains Woodcutter, Gold x2, <spare_hand_cards>
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Gold x2
      And it should be my Buy phase
    When I buy Farmland expecting side-effects
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have removed Adventurer from hand 
      And I should have gained Province
      And I should have gained Farmland
    And it should be my Buy phase
      And I should have 2 cash available
      
    Examples:
      | spare_hand_cards |
      | Adventurer       |
      | Adventurer x2    |
    
    
  Scenario: Buying Farmland with just one card in hand and no upgrade choices
    Given my hand contains Woodcutter, Gold x2, Province x3
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Gold x2
      And it should be my Buy phase
    When I buy Farmland expecting side-effects
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have removed Province from hand
      And I should have gained Farmland
    And it should be my Buy phase
      And I should have 2 cash available
  
 
  Scenario: Buying Farmland with no cards in hand
    Given my hand contains Woodcutter, Gold x2
      And it is my Play Action phase
    When I play Woodcutter
      And the game checks actions
    Then I should have played Gold x2
      And it should be my Buy phase
    When I buy Farmland
      And the game checks actions
    Then I should have gained Farmland
      And it should be my Buy phase
      And I should have 2 cash available
  
 
  Scenario: Gaining Farmland in non-buy means
    Given my hand contains Remodel x2
      And Bob's hand contains Smuggler
      And it is my Play Action phase
    When I play Remodel
      And the game checks actions
    Then I should have removed Remodel from my hand
      And I should need to Take a replacement card with Remodel
    When I choose the Farmland pile
      And the game checks actions
    Then I should have gained Farmland
      And it should be my Buy phase
    When Bob's next turn starts
    Then it should be Bob's Play Action phase
    When Bob plays Smuggler
      And the game checks actions
    Then Bob should have gained Farmland
      And it should be Bob's Buy phase

