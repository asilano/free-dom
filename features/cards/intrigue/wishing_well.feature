Feature: Wishing Well
  Draw 1 card, +1 Action. Name a card, then reveal the top card of your deck. If it's the named card, put it into your hand.
  
  Background:
    Given I am a player in a standard game with Wishing Well
    
  Scenario: Playing Wishing Well - hit card
    Given my hand contains Wishing Well and 4 other cards
      And my deck contains Silver, Gold
    When I play Wishing Well
    Then I should have drawn 1 card
      And I should need to Name a card, with Wishing Well
    When I choose the Gold pile
    Then I should have moved Gold from deck to hand
      And it should be my Play Action phase
      And I should have 1 action available
      
  Scenario: Playing Wishing Well - miss card
    Given my hand contains Wishing Well and 4 other cards
      And my deck contains Silver, Silver
    When I play Wishing Well
    Then I should have drawn 1 card
      And I should need to Name a card, with Wishing Well
    When I choose the Gold pile
    Then it should be my Play Action phase
      And I should have 1 action available
      
  Scenario: Playing Wishing Well - choosing a non-card
    Given my hand contains Wishing Well and 4 other cards
      And my deck contains Silver, Gold
    When I play Wishing Well
    Then I should have drawn 1 card
      And I should need to Name a card, with Wishing Well
    When I choose Ace of Spades for piles
    Then it should be my Play Action phase
      And I should have 1 action available
      
  Scenario: Playing Wishing Well - empty deck
    Given my hand contains Wishing Well and 4 other cards
      And my deck contains Silver
    When I play Wishing Well
    Then I should have drawn 1 card
      And I should need to Name a card, with Wishing Well
    When I choose the Gold pile
    Then it should be my Play Action phase
      And I should have 1 action available