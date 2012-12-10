Feature: Watchtower + Duchess
  Whatever Watchtower mode is applied to a gained Duchy, the Duchess should still be available (and WT'd), after the Duchy is gained

  Background:
    Given I am a player in a standard game with Duchess

  Scenario: Watchtower + Duchess
    Given my hand contains Village x2, Remodel x3, Silver x3, Watchtower
      And my deck contains Estate x5
      And it is my Play Action phase
    When I play Village
      Then I should have drawn a card
    When I play Village
      Then I should have drawn a card
    When I play Remodel
    And I choose Silver in my hand
      Then I should have removed Silver from my hand
    When I choose the Duchy pile
    And the game checks actions
      Then I should need to Decide on destination for Duchy
      And I should not need to Choose whether to gain a Duchess
    When I choose the option Yes - Duchy on deck
      Then I should have put Duchy on top of my deck
      And I should need to Choose whether to gain a Duchess
    When I choose the option Gain a Duchess
    And the game checks actions
      Then I should need to Decide on destination for Duchess
    When I choose the option No - Duchess to discard
      Then I should have gained Duchess
      And it should be my Play Action phase
    When I play Remodel
    And I choose Silver in my hand
      Then I should have removed Silver from my hand
    When I choose the Duchy pile
    And the game checks actions
      Then I should need to Decide on destination for Duchy
      And I should not need to Choose whether to gain a Duchess
    When I choose the option Yes - trash Duchy
      Then I should need to Choose whether to gain a Duchess
    When I choose the option Gain a Duchess
    And the game checks actions
      Then I should need to Decide on destination for Duchess
    When I choose the option Yes - Duchess on deck
      Then I should have put Duchess on top of my deck
      And it should be my Play Action phase
    When I play Remodel
    And I choose Silver in my hand
      Then I should have removed Silver from my hand
    When I choose the Duchy pile
    And the game checks actions
      Then I should need to Decide on destination for Duchy
      And I should not need to Choose whether to gain a Duchess
    When I choose the option No - Duchy to discard
      Then I should have gained Duchy
      And I should need to Choose whether to gain a Duchess
    When I choose the option Gain a Duchess
    And the game checks actions
      Then I should need to Decide on destination for Duchess
    When I choose the option Yes - trash Duchess
      Then it should be my Play Treasure phase