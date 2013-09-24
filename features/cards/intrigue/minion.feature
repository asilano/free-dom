Feature: Minion
  Attack - +1 Action. Choose one: +2 cash;
           or discard your hand and draw 4 cards, and each other player with 5 or more cards in hand discards his hand and draws 4.

  Background:
    Given I am a player in a standard game with Minion

  Scenario: Minion should be set up at game start
    Then there should be 10 Minion cards in piles
      And there should be 0 Minion cards not in piles

  Scenario: Playing nice Minion
    Given my hand contains Minion and 4 other cards
      And it is my Play Action phase
    When I play Minion
    And the game checks actions
      Then I should have 1 action available
      And I should need to Choose Minion mode
    When I choose the option +2 Cash
      Then I should have 2 cash
    When the game checks actions
      Then it should be my Play Action phase

  Scenario: Playing nasty Minion
    Given my hand contains Minion and 2 other cards named "rest of hand"
      And my deck contains Gold x5
      And Bob's hand contains 4 cards
      And Charlie's hand contains Gold, Witch, Village, Mountebank, Market
    When I play Minion
    And the game checks actions
      Then I should have 1 action available
      And I should need to Choose Minion mode
    When I choose the option Cycle hands
      And the game checks actions
    Then the following 4 steps should happen at once
      Then I should have discarded the cards named "rest of hand"
      And I should have drawn 4 cards
      And Charlie should have discarded Gold, Witch, Village, Mountebank, Market
      And Charlie should have drawn 4 cards
    And it should be my Play Action phase

  Scenario: Reactions should be requested before mode choice
    Given my hand contains Minion and 2 other cards named "rest of hand"
      And my deck contains Gold x5
      And Bob's hand contains Moat, Witch, Village, Mountebank, Market
      And Charlie's hand contains Secret Chamber, Witch, Village, Mountebank, Market
      And Bob has setting automoat off
    When I play Minion
    And the game checks actions
      Then I should have 1 action available
      And Charlie should need to React to Minion
      And Bob should need to React to Minion
    When Charlie chooses Don't react in his hand
    And Bob chooses Moat in his hand
    And Bob chooses Don't react in his hand
      Then I should need to Choose Minion mode
    When I choose the option Cycle hands
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have discarded the cards named "rest of hand"
        And I should have drawn 4 cards
        And Charlie should have discarded Secret Chamber, Witch, Village, Mountebank, Market
        And Charlie should have drawn 4 cards
    And it should be my Play Action phase