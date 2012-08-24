Feature: Vault
  Draw 2 cards. Discard any number of cards; +1 cash per card discarded
    Each other player may discard 2 cards; if he does, he draws a card.
  
  Background:
    Given I am a player in a standard game with Vault
  
  Scenario: Valut should be set up at game start
    Then there should be 10 Vault cards in piles
      And there should be 0 Vault cards not in piles
      
  Scenario Outline: Playing Vault (my side)
    Given my hand contains Vault, <otherhand>
      And my deck contains Estate x5
      And Bob's hand is empty
      And Charlie's hand is empty
      And it is my Play Action phase
    When I play Vault
      Then I should have drawn 2 cards
      Then I should need to Discard any number of cards, with Vault
    When I choose <choice> in my hand
    Then I should have discarded <choice>
      And I should have <cash> cash
      And it should be my Play Treasure phase
      
    Examples:
      | otherhand                      | choice                          | cash      |
      | Copper, Silver, Gold, Curse    | Copper, Curse                   | 2         |
      | Copper, Silver, Gold, Curse    |                                 | 0         |
      | Copper, Silver, Gold, Curse    | Copper, Curse, Gold, Estate x2  | 5         |
      | Copper, Silver, Gold, Curse    | Copper, Silver, Gold            | 3         |

  Scenario: Playing Vault (other players)
    Given my hand contains Vault
      And my deck is empty
      And Bob's hand contains Copper, Estate, Duchy
      And Charlie's hand contains Silver, Gold, Smithy, Market
      And it is my Play Action phase
    When I play Vault
      Then I should not need to act
      And Bob should need to Discard first card or choose not to, with Vault
      And Charlie should need to Discard first card or choose not to, with Vault
    When Bob chooses Estate in his hand
      Then Bob should have discarded Estate
      And Bob should need to Discard second card with Vault
    When Bob chooses Duchy in his hand
      Then the following 2 steps should happen at once
        Then Bob should have discarded Duchy
        And Bob should have drawn a card
    When Charlie chooses Discard nothing in his hand
      Then it should be my Play Treasure phase 

  Scenario: Playing Vault (other players automation)
    Given my hand contains Vault
      And my deck is empty
      And Bob's hand contains Copper, Copper, Duchy
      And Charlie's hand contains Silver
      And it is my Play Action phase
    When I play Vault
      Then I should not need to act
      And Bob should need to Discard first card or choose not to, with Vault
      And Charlie should need to Discard first card or choose not to, with Vault
    When Bob chooses Duchy in his hand
      Then the following 2 steps should happen at once
        Then Bob should have discarded Duchy, Copper
        And Bob should have drawn a card
    When Charlie chooses Silver in his hand
      Then Charlie should have discarded Silver
      And it should be my Play Treasure phase 