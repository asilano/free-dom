Feature: Haven
  Draw 1 card, +1 Action.
  Set aside a card from your hand face down. At the start of your next turn, put it into your hand.
  
  Background:
    Given I am a player in a standard game with Haven
    
  Scenario: Haven should be set up at game start
    Then there should be 10 Haven cards in piles
      And there should be 0 Haven cards not in piles
      
  Scenario: Playing Haven
    Given my hand contains Haven, Gold x4
      And my deck contains Estate x10
      And it is my Play Action phase
    When I play Haven
      Then I should have drawn 1 card
      And I should have 1 action available
      And I should need to Set a card aside with Haven
    When I choose Gold in my hand
      Then I should have removed Gold from my hand
      And it should be my Play Action phase
    When my next turn starts
    Then the following 2 steps should happen at once
      Then I should have moved Haven from enduring to play
      And I should have gained Gold into my hand
    And I should have 1 action available
    
  Scenario: Playing Haven with only one kind of card: auto-choose that card
    Given my hand contains Haven, Gold x4
      And my deck contains Gold x10
      And it is my Play Action phase
    When I play Haven
      Then the following 2 steps should happen at once
        Then I should have drawn 1 card
        And I should have removed Gold from my hand
      And I should have 1 action available
      And it should be my Play Action phase
    When my next turn starts
    Then the following 2 steps should happen at once
      Then I should have moved Haven from enduring to play
      And I should have gained Gold into my hand
    And I should have 1 action available
    
  Scenario: Playing Haven with no cards left in hand/deck/discard to set aside
    Given my hand contains Haven
      And my deck is empty
      And it is my Play Action phase
    When I play Haven
      Then I should have 1 action available
      And it should be my Play Action phase
    When my next turn starts
    Then I should have moved Haven from enduring to play
    And I should have 1 action available

  Scenario: Playing multiple Havens
    Given my hand contains Haven x2, Gold x3
      And my deck contains Estate, Gold
      And it is my Play Action phase
    When I play Haven
      Then I should have drawn 1 card
      And I should have 1 action available
      And I should need to Set a card aside with Haven
    When I choose Estate in my hand
      Then I should have removed Estate from my hand
      And it should be my Play Action phase
    When I play Haven
      Then the following 2 steps should happen at once
        Then I should have drawn 1 card
        And I should have removed Gold from my hand
      And I should have 1 action available
    When my next turn starts
    Then the following 2 steps should happen at once
      Then I should have moved Haven x2 from enduring to play
      And I should have placed Estate, Gold into my hand
    And I should have 1 action available
    
  Scenario: Playing Haven with Throne Room
    Given my hand contains Haven, Throne Room, Gold x3
      And my deck contains Estate, Gold
      And it is my Play Action phase
    When I play Throne Room
      And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have moved Throne Room from play to enduring
        And I should have moved Haven from hand to enduring
      And I should have drawn 1 card
      And I should need to Set a card aside with Haven
    When I choose Estate in my hand
      Then I should have removed Estate from my hand
    When the game checks actions
      Then the following 2 steps should happen at once
        Then I should have drawn 1 card
        And I should have removed Gold from my hand
      And I should have 2 actions available
      And it should be my Play Action phase
    When my next turn starts
    Then the following 2 steps should happen at once
      Then I should have moved Haven, Throne Room from enduring to play
      And I should have placed Estate, Gold into my hand
    And I should have 1 action available
