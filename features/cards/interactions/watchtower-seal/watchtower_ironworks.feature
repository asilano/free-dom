Feature: Ironworks + Watchtower
  Watchtower should apply before Ironworks; that is, if you IW a Great Hall, you should be able to draw the GH.

  Background:
    Given I am a player in a standard game with Great Hall

  Scenario:
    Given my hand contains Ironworks, Watchtower
      And my deck contains Estate
    When I play Ironworks
    And I choose the Great Hall pile
    And the game checks actions
      Then I should need to Decide on destination for Great Hall
    When I choose the option Yes - Great Hall on deck
      Then I should have put Great Hall on top of my deck
    When the game checks actions
      Then I should have drawn a card
      And it should be my Play Action phase
      And I should have Great Hall, Watchtower in my hand