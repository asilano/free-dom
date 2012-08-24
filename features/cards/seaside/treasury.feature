Feature: Treasury
  Draw 1 card, +1 Action, +1 Cash.
  When you discard this from play, if you didn't buy a Victory card this turn, you may put this on top of your deck.
    
  Background:
    Given I am a player in a standard game with Treasury, Island, Harem, Nobles, Colony
      And my hand contains Treasury, Gold x4
      And my deck contains Silver x4, Estate x5
      And it is my Play Action phase
      And I have setting autotreasury off
      # Testing the controls is easiest with autotreasury off
      # Setting will be overridden in the autotreasury-on testpoints
  
  Scenario Outline: Playing Treasury 
    When I play Treasury
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash available
    When I stop playing actions
      And the game checks actions
    Then I should have played Gold x4, Silver
      And it should be my Buy phase
    When I buy <card>
      And the game checks actions
    Then the following 3 steps should happen at once
      Then I should have gained <card>
      And I should have moved Gold x4, Silver from play to discard
      And I should need to Choose where to place Treasury
    When I choose the option <choice>
      And the game checks actions
    Then the following 2 steps should happen at once
      Then I should have moved Treasury from play to <destination>
      And I should have drawn 5 cards
        
    Examples:
      | card     | choice      | destination |
      | Gold     | Top of deck | deck        |
      | Curse    | Top of deck | deck        |
      | Silver   | Discard     | discard     |
      | Treasury | Discard     | discard     |
        
  Scenario Outline: Playing Treasury - no option if bought victory card
    When I play Treasury
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash available
    When I stop playing actions
      And the game checks actions
    Then I should have played Gold x4, Silver
      And it should be my Buy phase
    When I buy <card>
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have gained <card>
      And I should have moved Gold x4, Silver, Treasury from play to discard
      And I should have drawn 5 cards
    And I should not need to act
    And it should be Bob's Play Action phase
    
    Examples:
      | card     |
      | Province |
      | Colony   |
      | Island   |
      | Harem    |
      | Nobles   |
      
  Scenario Outline: Playing Treasury - respects autotreasury setting
    Given I have setting autotreasury on
    When I play Treasury
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash available
    When I stop playing actions
      And the game checks actions
    Then I should have played Gold x4, Silver
      And it should be my Buy phase
    When I buy Gold
      And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have gained Gold
        And I should have moved Treasury from play to deck
        And I should have moved Gold x4, Silver from play to discard
        And I should have drawn 5 cards
      
  Scenario: Playing multiple Treasuries with autotreasury on - they all automove
    Given my hand contains Treasury x2, Gold x3
      And I have setting autotreasury on
    When I play Treasury
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash available
    When I play Treasury
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 2 cash available
    When I stop playing actions
      And the game checks actions
    Then I should have played Gold x3, Silver x2
      And it should be my Buy phase
    When I buy Gold
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have gained Gold
      And I should have moved Gold x3, Silver x2 from play to discard
      And I should have moved Treasury x2 from play to deck
      And I should have drawn 5 cards
      
  Scenario: Playing multiple Treasuries with autotreasury off - get controls for all of them
    Given my hand contains Treasury x2, Gold x3
    When I play Treasury
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 1 cash available
    When I play Treasury
    Then I should have drawn 1 card
      And I should have 1 action available
      And I should have 2 cash available
    When I stop playing actions
      And the game checks actions
    Then I should have played Gold x3, Silver x2
      And it should be my Buy phase
     When I buy Gold
       And the game checks actions
     Then the following 3 steps should happen at once
       Then I should have gained Gold
       And I should have moved Gold x3, Silver x2 from play to discard
       And I should need to Choose where to place Treasury
     When I choose the option Top of deck
       And the game checks actions
     Then I should have moved Treasury from play to deck
       And I should need to Choose where to place Treasury
     When I choose the option Discard
       And the game checks actions
     Then the following 2 steps should happen at once
       Then I should have moved Treasury from play to discard
       And I should have drawn 5 cards
  
  Scenario: Treasury should be set up at game start
    Given I am a player in a standard game with Treasury
    Then there should be 10 Treasury cards in piles
      And there should be 0 Treasury cards not in piles
      