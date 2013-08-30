Feature: Peddler bought with Talisman
  A Peddler made cheap enough should be doubled by Talisman, even as the last buy

  Background:
    Given I am a player in a standard game with Peddler

  Scenario:
    Given my hand contains Market, Smithy
      And my deck contains Talisman, Gold x3
      And it is my Play Action phase
    When I play Market
      Then I should have drawn a card
    When I play Smithy
      Then I should have drawn 3 cards
    When the game checks actions
      Then I should have played Talisman, Gold x3
      And the Peddler pile should cost 4
      And I should have 2 buys available
    When I buy Peddler
    And the game checks actions
      Then I should have gained Peddler x2
    When I buy Peddler
    And the game checks actions
      Then the following 2 steps should happen at once
        Then I should have gained Peddler x2
        And I should have ended my turn