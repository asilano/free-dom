Feature: Ambassador
  Reveal a card from your hand. Return up to 2 copies of it from your hand to the Supply. Then each other player gains a copy of it.
  
  Background:
    Given I am a player in a standard game with Ambassador
    
  Scenario: Ambassador should be set up at game start
    Then there should be 10 Ambassador cards in piles
      And there should be 0 Ambassador cards not in piles
      
  Scenario: Playing Ambassador - return 2
    Given my hand contains Ambassador, Estate x2, Curse x2
      And it is my Play Action phase
    When I play Ambassador
      Then I should need to Reveal a card with Ambassador
      And I should not be able to choose a nil action in my hand
    When I choose Curse in my hand
      Then I should need to Return up to 2 cards with Ambassador
    When I choose Curse in my hand
      Then I should have removed Curse from my hand
      And I should need to Return another card with Ambassador
    When I choose Curse in my hand
      Then I should have removed Curse from my hand
    When the game checks actions
      Then the following 2 steps should happen at once
        Then Bob should have gained Curse
        And Charlie should have gained Curse
    And it should be my Buy phase
      
  Scenario: Playing Ambassador - return 1
    Given my hand contains Ambassador, Estate x2, Curse x2
      And it is my Play Action phase
    When I play Ambassador
      Then I should need to Reveal a card with Ambassador
    When I choose Curse in my hand
      Then I should need to Return up to 2 cards with Ambassador
    When I choose Curse in my hand
      Then I should have removed Curse from my hand
      And I should need to Return another card with Ambassador
    When I choose Return no more in my hand
      And the game checks actions
      Then the following 2 steps should happen at once
        Then Bob should have gained Curse
        And Charlie should have gained Curse
    And it should be my Buy phase
      
  Scenario: Playing Ambassador - return 0
    Given my hand contains Ambassador, Estate x2, Curse x2
      And it is my Play Action phase
    When I play Ambassador
      Then I should need to Reveal a card with Ambassador
    When I choose Curse in my hand
      Then I should need to Return up to 2 cards with Ambassador
    When I choose Return no more in my hand
      And the game checks actions
      Then the following 2 steps should happen at once
        Then Bob should have gained Curse
        And Charlie should have gained Curse
    And it should be my Buy phase
      
  Scenario: Playing Ambassador - all cards in hand the same
    Given my hand contains Ambassador, Estate x4
      And it is my Play Action phase
    When I play Ambassador
      Then I should need to Return up to 2 cards with Ambassador
    When I choose Return no more in my hand
      And the game checks actions
      Then the following 2 steps should happen at once
        Then Bob should have gained Estate
        And Charlie should have gained Estate
    And it should be my Buy phase
      
  Scenario: Playing Ambassador - limited number in piles
    Given my hand contains Ambassador, Curse x4
      And the Curse pile contains 1 card
      And it is my Play Action phase
    When I play Ambassador
      Then I should need to Return up to 2 cards with Ambassador
    When I choose Return no more in my hand
      And the game checks actions
      Then Bob should have gained Curse
    And it should be my Buy phase
      
  Scenario: Playing Ambassador - 0 cards in hand
    Given my hand contains Ambassador
      And it is my Play Action phase
    When I play Ambassador
      And the game checks actions
    Then it should be my Buy phase
      
  Scenario: Playing Ambassador - counts as attack (defended against by Lighthouse)
    Given my hand contains Ambassador, Estate x4
      And Bob has Lighthouse as a duration
      And it is my Play Action phase
    When I play Ambassador
      Then I should need to Return up to 2 cards with Ambassador
    When I choose Return no more in my hand
      And the game checks actions
      Then Charlie should have gained Estate
    And it should be my Buy phase
