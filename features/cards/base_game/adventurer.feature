Feature: Adventurer  
  Reveal cards from your deck until you reveal two Treasure cards. 
  Put those Treasure cards into your hand, and discard the other revealed cards.
  
  Background:
    Given I am a player in a standard game with Adventurer
  
  Scenario: Adventurer should be set up at game start
    Then there should be 10 Adventurer cards in piles
      And there should be 0 Adventurer cards not in piles
      
  Scenario Outline: Playing Adventurer
    Given my hand contains Adventurer
      And my deck contains <deck cards>
      And I have nothing in play
      And I have <discard> in discard
      And it's my Play Action phase
    When I play Adventurer
    Then the following 2 steps should happen at once
        Then I should have drawn <from deck> cards
        And I should have discarded <discarded>      
      And it should be my Play Treasure phase
      
    Examples:
      | deck cards                        | discard             | from deck | discarded                   |
      | Copper, Gold then 3 other cards   | nothing             |    2      | nothing                     |
      | Copper, Curse, Curse, Gold        | nothing             |    4      | Curse, Curse                |
      | Curse, Copper, Curse, Gold, Curse | nothing             |    4      | Curse, Curse                |
      | Curse, Curse, Copper, Curse       | Curse, Harem, Wharf |    6      | Curse, Curse, Curse, Curse  |
      | Curse, Copper                     | Curse, Curse        |    4      | Curse, Curse, Curse         |
      | Curse, Copper, Curse              | nothing             |    3      | Curse, Curse                |
      | 0 cards                           | Copper, Curse, Gold |    3      | Curse                       |
      | Curse, Curse                      | Curse               |    3      | Curse, Curse, Curse         |