Feature: Secret Chamber
  Discard any number of cards; +1 cash per card discarded
  (Reaction) - When another player plays an Attack card, you may reveal this from your hand. 
    If you do, draw 2 cards, then put 2 cards from your hand on top of your deck.
  
  Background:
    Given I am a player in a standard game with Secret Chamber
  
  Scenario: Secret Chamber should be set up at game start
    Then there should be 10 Secret Chamber cards in piles
      And there should be 0 Secret Chamber cards not in piles
      
  Scenario Outline: Playing Secret Chamber
    Given my hand contains Secret Chamber, <otherhand>
      And it is my Play Action phase
    When I play Secret Chamber
    Then I should need to Discard any number of cards, with Secret Chamber
    When I choose <choice> in my hand
    Then I should have discarded <choice>
      And I should have <cash> cash
      And it should be my Play Treasure phase
      
    Examples:
      | otherhand                      | choice               | cash      |
      | Copper, Silver, Gold, Curse    | Copper, Curse        | 2         |
      | Copper, Silver, Gold, Curse    |                      | 0         |
      | Copper, Silver, Gold, Curse    | Copper, Curse        | 2         |
      | Copper, Silver, Gold, Curse    | Copper, Silver, Gold | 3         |
      
  Scenario: Ask to react to attack
    Given my hand contains Secret Chamber, Estate, Duchy, Smithy, Witch
      And Bob's hand contains Bureaucrat and 4x Market
      And Charlie's hand is empty
      And it is Bob's Play Action phase
    When Bob plays Bureaucrat
      And the game checks actions
    Then Bob should have put Silver on top of his deck
      And I should need to React to Bureaucrat
    When I choose Secret Chamber in my hand
    Then I should have drawn 2 cards
      And I should need to Place a card second-from-top of deck with Secret Chamber
    When I choose Estate in my hand
      Then I should have moved Estate from hand to deck
      And I should need to Place a card on top of deck with Secret Chamber
    When I choose Duchy in my hand
      Then I should have moved Duchy from hand to deck
      And I should need to React to Bureaucrat
    When I choose Don't react in my hand
      And the game checks actions
    Then I should not need to act
      And it should be Bob's Buy phase
      
  Scenario: Choose not to prevent attack
    Given my hand contains Secret Chamber, Estate, Duchy and 4 other cards
      And Bob's hand contains Bureaucrat and 4x Market
      And Charlie's hand is empty
      And it is Bob's Play Action phase
    When Bob plays Bureaucrat
      And the game checks actions
    Then Bob should have put Silver on top of his deck
      And I should need to React to Bureaucrat
    When I choose Don't react in my hand
      And the game checks actions
    Then I should need to Place a Victory card onto deck

  Scenario: Secret Chamber doesn't protect against your attacks
    Given my hand contains Secret Chamber, Spy and 3 other cards
      And my deck contains Copper
      And Bob's deck contains Silver
      And Charlie's deck contains Gold
      And it is my Play Action phase
    When I play Spy
      And the game checks actions
    Then I should have drawn 1 card
      And I should need to Choose Spy actions for Alan
      And I should need to Choose Spy actions for Bob
      And I should need to Choose Spy actions for Charlie 