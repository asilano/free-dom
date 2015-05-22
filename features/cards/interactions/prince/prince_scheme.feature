Feature:
  Prince works fine with Scheme as long as Scheme picks another card.
  The Scheme isn't replayed if it ever chooses itself.
  Another Princed card ceases being Princed if Scheme chooses it.

  Background:
    Given I am a player in a standard game

  Scenario: Prince works with Scheme choosing another card
    Given my hand contains Prince, Scheme
      And my deck contains Estate x5, Woodcutter
      And it is my Play Action phase
    When I play Prince
    And I choose Scheme in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Scheme from my hand
        And I should have removed Prince from play
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Scheme in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play Woodcutter
    And my turn is about to end
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
    When I choose Woodcutter in play
      Then I should have moved Woodcutter from play to deck
    When the game checks actions
      Then the following 3 steps should happen at once
        Then I should have removed Scheme from play
        And I should have discarded my hand
        And I should have drawn 5 cards
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Scheme in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase

  Scenario: Prince works with Scheme choosing nothing
    Given my hand contains Prince, Scheme
      And my deck contains Estate x5, Woodcutter
      And it is my Play Action phase
    When I play Prince
    And I choose Scheme in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Scheme from my hand
        And I should have removed Prince from play
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Scheme in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play Woodcutter
    And my turn is about to end
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
    When I choose Choose nothing in play
    And the game checks actions
      Then the following 4 steps should happen at once
        Then I should have removed Scheme from play
        And I should have discarded my in-play cards
        And I should have discarded my hand
        And I should have drawn 5 cards
    When my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Scheme in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase

  Scenario: Prince works badly with Scheme choosing itself
    Given my hand contains Prince, Scheme
      And my deck contains Estate x5, Woodcutter
      And it is my Play Action phase
    When I play Prince
    And I choose Scheme in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Scheme from my hand
        And I should have removed Prince from play
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have placed Scheme in play
        And I should have drawn a card
      And I should have 2 actions available
      And it should be my Play Action phase
    When I play Woodcutter
    And my turn is about to end
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
    When I choose Scheme in play
      Then I should have moved Scheme from play to deck
    When the game checks actions
      Then the following 3 steps should happen at once
        Then I should have discarded my in-play cards
        And I should have discarded my hand
        And I should have drawn 5 cards
    When my next turn is about to start
    And the game checks actions
      Then it should be my Play Action phase


  Scenario: Prince works badly if its card becomes Schemed
    Given my hand contains Prince, Woodcutter
      And my deck contains Scheme, Estate x5
      And it is my Play Action phase
    When I play Prince
    And I choose Woodcutter in my hand
      Then the following 2 steps should happen at once
        Then I should have removed Woodcutter from my hand
        And I should have removed Prince from play
    When the game checks actions
    And my next turn is about to start
    And the game checks actions
      Then I should have placed Woodcutter in play
      And I should have 2 cash
      And I should have 2 buys available
      And it should be my Play Action phase
    When I play Scheme
      Then I should have drawn a card
    When my turn is about to end
    And the game checks actions
      Then I should need to Choose an Action card to return with Scheme
    When I choose Woodcutter in play
      Then I should have moved Woodcutter from play to deck
    When the game checks actions
      Then the following 3 steps should happen at once
        Then I should have discarded my in-play cards
        And I should have discarded my hand
        And I should have drawn 5 cards
    When my next turn is about to start
    And the game checks actions
      Then it should be my Play Action phase
