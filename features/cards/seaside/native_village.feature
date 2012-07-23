Feature: Native Village
  +2 Actions.
  Choose one: Set aside the top card of your deck face down on your Native Village mat; or put all the cards from your mat into your hand. 
  You may look at the cards on your mat at any time; return them to your deck at the end of the game.
  
  Background:
    Given I am a player in a standard game with Native Village
    
  Scenario: Native Village should be set up at game start
    Then there should be 10 Native Village cards in piles
      And there should be 0 Native Village cards not in piles
      
  Scenario: Playing Native Village - set aside, set aside, return
    Given my hand contains Native Village x3
      And my deck contains Gold x2, Estate x10
      And it is my Play Action phase
    When I play Native Village
      Then I should have 2 actions available
      And I should need to Choose Native Village's mode
    When I choose the option Set top card aside
      Then I should have removed Gold from my deck
    When I play Native Village
      Then I should have 3 actions available
      And I should need to Choose Native Village's mode
    When I choose the option Set top card aside
      Then I should have removed Gold from my deck
    When I play Native Village
      Then I should have 4 actions available
      And I should need to Choose Native Village's mode
    When I choose the option Reclaim set-aside cards
      Then I should have gained Gold, Gold into my hand      
    
  Scenario: Playing Native Village with no cards left in deck/discard to set aside
    Given my hand contains Native Village and 4 other cards
      And my deck is empty
      And it is my Play Action phase
    When I play Native Village
      Then I should have 2 actions available
      And I should need to Choose Native Village's mode
    When I choose the option Set top card aside
      And it should be my Play Action phase
    
  Scenario: Playing Native Village in return mode with no cards set aside to return
    Given my hand contains Native Village and 4 other cards
      And my deck contains Copper x10
      And it is my Play Action phase
    When I play Native Village
      Then I should have 2 actions available
      And I should need to Choose Native Village's mode
    When I choose the option Reclaim set-aside cards
      Then it should be my Play Action phase
    
  Scenario: Set aside cards still contribute score
    Given my hand contains Native Village, Copper x4
      And my deck contains Province
      And it is my Play Action phase
    When I play Native Village
      Then I should have 2 actions available
      And I should need to Choose Native Village's mode
    When I choose the option Set top card aside
      Then I should have removed Province from my deck
    When the game ends
      Then my score should be 6