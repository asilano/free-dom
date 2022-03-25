# Action (cost: 5) - +1 Card
# +1 Action
# Reveal the top 3 cards of your deck. Put the ones costing from $2 to $4 into your hand. Put the rest back in any order.
Feature: Seer
  Background:
    Given I am in a 3 player game
    And my hand contains Seer, Market, Cargo Ship, Gold, Village
    And the kingdom choice contains Seer
    Then I should need to "Play an Action, or pass"

  Scenario: Playing Seer, hit various cards
    Given my deck contains Curse, <deck_cards>
    When I choose Seer in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And I should reveal 3 cards from my deck
      And I should move <mid_cost_cards> from my deck to my hand
      And I should unreveal <unreveal_cards> from my deck
      And these card moves should happen
    And I should need to "<next_question>"
    Examples:
        | deck_cards               | mid_cost_cards           | unreveal_cards | next_question                          |
        | Copper, Market, Gold     | nothing                  | nothing        | Reorder the cards on top of your deck  |
        | Copper, Village, Gold    | Village                  | nothing        | Reorder the cards on top of your deck  |
        | Village, Cellar, Gold    | Village, Cellar          | Gold           | Play an Action, or pass                |
        | Silver, Cellar, Inventor | Silver, Cellar, Inventor | nothing        | Play an Action, or pass                |

  Scenario: Playing Seer, rearrangement handling
    Given my deck contains Curse, Copper, Village, Gold
    When I choose Seer in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And I should reveal 3 cards from my deck
      And I should move Village from my deck to my hand
      And these card moves should happen
    And I should need to 'Reorder the cards on top of your deck'
    When I choose '1st (topmost)' for Gold, '2nd (bottommost)' for Copper in my revealed cards
    Then cards should move as follows:
      Then I should move Gold, Copper from my deck to my deck
      And these card moves should happen
    And my deck should contain Gold, Copper
    And I should need to "Play an Action, or pass"

  Scenario: Playing Seer, not enough in deck
    Given my deck contains Curse, Copper, Village
    When I choose Seer in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And I should reveal 3 cards from my deck
      And I should move Village from my deck to my hand
      And I should unreveal Copper from my deck
      And these card moves should happen
    And I should need to "Play an Action, or pass"

  Scenario: Playing Seer, reveal Patron
    Given the kingdom choice contains Seer, Patron
    And my deck contains Curse, Copper, Village, Patron
    When I choose Seer in my hand
    Then cards should move as follows:
      Then I should draw 1 card
      And I should reveal 3 cards from my deck
      And I should move Village, Patron from my deck to my hand
      And I should unreveal Copper from my deck
      And these card moves should happen
    And I should have 1 Coffers
    And I should need to "Play an Action, or pass"

  # Needs Alchemy or Empires
  Scenario: Playing Seer, hit card costing debt or potion
    Given pending