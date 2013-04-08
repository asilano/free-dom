Feature: Scout
  +1 Action. Reveal the top 4 cards of your deck. Put the revealed Victory cards into your hand.
            Put the other cards on top of your deck in any order.

  Background:
    Given I am a player in a standard game with Scout

  Scenario: Scout should be set up at game start
    Then there should be 10 Scout cards in piles
      And there should be 0 Scout cards not in piles

  Scenario: Playing Scout - normal cards
    Given my hand contains Scout and 4 other cards
      And my deck contains Smithy, Estate, Silver, Curse
    When I play Scout
    Then I should have moved card 1 from deck to hand
      And I should be revealing Smithy, Silver, Curse
    And the following 5 steps should happen at once
      And I should need to Put a card 3rd from top with Scout
      When I choose my revealed Silver
      Then I should need to Put a card 2nd from top with Scout
      When I choose my revealed Curse
      Then I should have Smithy, Curse, Silver on my deck
    And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Scout - cards with subtypes
    Given my hand contains Scout and 4 other cards
      And my deck contains Moat, Estate, Lighthouse, Duchy
    When I play Scout
    Then I should have moved cards 1,3 from deck to hand
      And I should be revealing Moat, Lighthouse
    And the following 3 steps should happen at once
      Then I should need to Put a card 2nd from top with Scout
      When I choose my revealed Moat
      Then I should have Lighthouse, Moat on my deck
    And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Scout - Hybrid cards; and 3 moved
    Given my hand contains Scout and 4 other cards
      And my deck contains Nobles, Harem, Great Hall, Smithy
    When I play Scout
    Then I should have moved cards 0,1,2 from deck to hand
      And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Scout - all 4 moved
    Given my hand contains Scout and 4 other cards
      And my deck contains Nobles, Harem, Great Hall, Duchy
    When I play Scout
    Then I should have moved cards 0,1,2,3 from deck to hand
      And it should be my Play Action phase
      And I should have 1 action available

  Scenario: Playing Scout - small deck
    Given my hand contains Scout and 4 other cards
      And my deck contains Estate, Smithy, Witch
    When I play Scout
    Then I should have moved card 0 from deck to hand
      And I should be revealing Smithy, Witch
    And the following 3 steps should happen at once
      Then I should need to Put a card 2nd from top with Scout
      When I choose my revealed Witch
      Then I should have Smithy, Witch on my deck
    And it should be my Play Action phase
      And I should have 1 action available