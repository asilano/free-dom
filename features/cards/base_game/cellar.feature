Feature: Cellar
  +1 Action. Discard any number of cards. Draw 1 card per card discarded

  Background:
    Given I am a player in a standard game with Cellar

  Scenario: Cellar should be set up at game start
    Then there should be 10 Cellar cards in piles
      And there should be 0 Cellar cards not in piles

  Scenario Outline: Playing Cellar
    Given my hand contains Cellar, <otherhand>
      And my deck contains <decksize> cards
      And I have <discardsize> cards in discard
      And it is my Play Action phase
    When I play Cellar
    Then I should need to Discard any number of cards, with Cellar
    When I choose <choice> in my hand
      Then I should have discarded <choice>
    When the game checks actions
      Then I should have drawn <drawnsize> cards
      And it should be my Play Action phase
      And I should have 1 action available

    Examples:
      | otherhand                      | decksize | discardsize | choice               | drawnsize |
      | Copper, Silver, Gold, Curse    | 5        | 0           | Copper, Curse        | 2         |
      | Copper, Silver, Gold, Curse    | 5        | 0           |                      | 0         |
      | Copper, Silver, Gold, Curse    | 1        | 3           | Copper, Curse        | 2         |
      | Copper, Silver, Gold, Curse    | 0        | 0           | Copper, Silver, Gold | 3         |