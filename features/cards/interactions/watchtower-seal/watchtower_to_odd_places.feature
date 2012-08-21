Feature: Watchtower applying to cards gained to odd places
  If a card is to be gained other than to discard, Watchtower should provide the options:
    * To top of deck
    * Trash
    * To original target location
    
  Background:
    Given I am a player in a 2-player standard game
    
  Scenario: Sea Hag (to top of deck)
    Given my hand contains Watchtower
      And my deck contains Copper x2
      And Bob's hand contains Sea Hag
      And it is Bob's Play Action phase
    When Bob plays Sea Hag
    And the game checks actions
      Then I should have moved Copper from deck to discard
      And I should need to Decide on destination for Curse
