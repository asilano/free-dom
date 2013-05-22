Feature: Cartographer
  Draw 1 card, +1 Action. Look at the top 4 cards of your deck.
  Discard any number of them. Put the rest back on top in any order.

  Background:
    Given I am a player in a standard game with Cartographer

  Scenario: Cartographer should be set up at game start
    Then there should be 10 Cartographer cards in piles
      And there should be 0 Cartographer cards not in piles

  Scenario: Playing Cartographer; force ordering choice
    Given my hand contains Cartographer
      And my deck contains Mine, Adventurer, Bazaar, Chancellor, Duchy, Gold x4
      And it is my Play Action phase
    When I play Cartographer
      Then I should have drawn a card
      And I should have 1 action available
      And I should have seen Adventurer, Bazaar, Chancellor, Duchy
      And I should need to Discard any number of cards with Cartographer
    When I choose my peeked Adventurer, Duchy
      Then I should have moved cards 0,3 from deck to discard
      And I should need to Put a card 2nd from top with Cartographer
    When I choose my peeked Bazaar
      Then the following 3 steps should happen at once
        Then I should have removed Bazaar, Chancellor from my deck
        And I should have put Bazaar on top of my deck
        And I should have put Chancellor on top of my deck
      And it should be my Play Action phase

  Scenario: Playing Cartographer; discard none
    Given my hand contains Cartographer
      And my deck contains Mine, Adventurer, Bazaar, Chancellor, Duchy, Gold x4
      And it is my Play Action phase
    When I play Cartographer
      Then I should have drawn a card
      And I should have 1 action available
      And I should have seen Adventurer, Bazaar, Chancellor, Duchy
      And I should need to Discard any number of cards with Cartographer
    When I choose none of my peeked cards
      Then I should need to Put a card 4th from top with Cartographer
    When I choose my peeked Bazaar
    And the game checks actions
      # because the deck only gets renumbered when actions are checked
      Then the following 2 steps should happen at once
        Then I should have removed Bazaar from my deck
        And I should have put Bazaar on top of my deck
      And I should need to Put a card 3rd from top with Cartographer
    When I choose my peeked Duchy
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have removed Duchy from my deck
        And I should have put Duchy on top of my deck
      And I should need to Put a card 2nd from top with Cartographer
    When I choose my peeked Adventurer
    And the game checks actions
      Then the following 3 steps should happen at once
        Then I should have removed Adventurer, Chancellor from my deck
        And I should have put Adventurer on top of my deck
        And I should have put Chancellor on top of my deck
      And it should be my Play Action phase

  Scenario: Playing Cartographer; discard 3
    Given my hand contains Cartographer
      And my deck contains Mine, Adventurer, Bazaar, Chancellor, Duchy, Gold x4
      And it is my Play Action phase
    When I play Cartographer
      Then I should have drawn a card
      And I should have 1 action available
      And I should have seen Adventurer, Bazaar, Chancellor, Duchy
      And I should need to Discard any number of cards with Cartographer
    When I choose my peeked Adventurer, Bazaar, Duchy
      Then I should have moved cards 0,1,3 from deck to discard
      And it should be my Play Action phase

  Scenario: Playing Cartographer; discard all
    Given my hand contains Cartographer
      And my deck contains Mine, Adventurer, Bazaar, Chancellor, Duchy, Gold x4
      And it is my Play Action phase
    When I play Cartographer
      Then I should have drawn a card
      And I should have 1 action available
      And I should have seen Adventurer, Bazaar, Chancellor, Duchy
      And I should need to Discard any number of cards with Cartographer
    When I choose my peeked Adventurer, Bazaar, Chancellor, Duchy
      Then I should have moved Adventurer, Bazaar, Chancellor, Duchy from deck to discard
      And it should be my Play Action phase

  Scenario: Playing Cartographer; reveal 3, discard 1
    Given my hand contains Cartographer
      And my deck contains Mine, Adventurer, Bazaar, Chancellor
      And it is my Play Action phase
    When I play Cartographer
      Then I should have drawn a card
      And I should have 1 action available
      And I should have seen Adventurer, Bazaar, Chancellor
      And I should need to Discard any number of cards with Cartographer
    When I choose my peeked Bazaar
      Then I should have moved card 1 from deck to discard
      And I should need to Put a card 2nd from top with Cartographer
    When I choose my peeked Adventurer
      Then the following 3 steps should happen at once
        Then I should have removed Adventurer, Chancellor from my deck
        And I should have put Adventurer on top of my deck
        And I should have put Chancellor on top of my deck
      And it should be my Play Action phase

  Scenario: Playing Cartographer; reveal 3, discard 2
    Given my hand contains Cartographer
      And my deck contains Mine, Adventurer, Bazaar, Chancellor
      And it is my Play Action phase
    When I play Cartographer
      Then I should have drawn a card
      And I should have 1 action available
      And I should have seen Adventurer, Bazaar, Chancellor
      And I should need to Discard any number of cards with Cartographer
    When I choose my peeked Adventurer, Chancellor
      Then I should have moved cards 0,2 from deck to discard
      And it should be my Play Action phase

  Scenario: Playing Cartographer; reveal 3, discard all
    Given my hand contains Cartographer
      And my deck contains Mine, Adventurer, Bazaar, Chancellor
      And it is my Play Action phase
    When I play Cartographer
      Then I should have drawn a card
      And I should have 1 action available
      And I should have seen Adventurer, Bazaar, Chancellor
      And I should need to Discard any number of cards with Cartographer
    When I choose my peeked Adventurer, Bazaar, Chancellor
      Then I should have moved Adventurer, Bazaar, Chancellor from deck to discard
      And it should be my Play Action phase

  Scenario: Playing Cartographer; reveal nothing
    Given my hand contains Cartographer
      And my deck contains Mine
      And it is my Play Action phase
    When I play Cartographer
      Then I should have drawn a card
      And I should have 1 action available
      And it should be my Play Action phase