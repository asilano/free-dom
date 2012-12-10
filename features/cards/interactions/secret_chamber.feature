Feature: Secret Chamber in conjuction with Moat and Lighthouse
  Should be able to use SC to find a Moat, Moat the attack, and put the Moat back
  Should be able to SC even under a Lighthouse
  
  Background:
    Given I am a player in a standard game
    
  Scenario: SC to find Moat
    Given my hand contains Secret Chamber, Estate x4
      And my deck contains Moat, Silver
      And Bob's hand contains Witch
      And Bob's deck contains Estate x5
      And Charlie has Lighthouse as a duration
      And it is Bob's Play Action phase
    When Bob plays Witch
      Then Bob should have drawn 2 cards
    When the game checks actions
      Then I should need to React to Witch
    When I choose Secret Chamber in my hand
      Then I should have drawn 2 cards
      And I should need to Place a card second-from-top of deck with Secret Chamber
    When I choose Estate in my hand
      Then I should have moved Estate from hand to deck
      And I should need to Place a card on top of deck with Secret Chamber
    When I choose Estate in my hand
      Then I should have moved Estate from hand to deck
      And I should need to React to Witch
    When I choose Moat in my hand
      Then I should need to React to Witch
    When I choose Secret Chamber in my hand
      Then I should have drawn 2 cards
      And I should need to Place a card second-from-top of deck with Secret Chamber
    When I choose Silver in my hand
      Then I should have moved Silver from hand to deck
      And I should need to Place a card on top of deck with Secret Chamber
    When I choose Moat in my hand
      Then I should have moved Moat from hand to deck
      And I should need to React to Witch
    When I choose Don't react in my hand
    And the game checks actions
      Then nothing should have happened
      And it should be Bob's Buy phase
      
  Scenario: SC when protected by Lighthouse
    Given my hand contains Secret Chamber, Estate x4
      And my deck contains Silver, Silver
      And I have Lighthouse as a duration
      And Bob's hand contains Witch
      And Bob's deck contains Estate x5
      And Charlie has Lighthouse as a duration
      And it is Bob's Play Action phase
    When Bob plays Witch
      Then Bob should have drawn 2 cards
    When the game checks actions
      Then I should need to React to Witch
    When I choose Secret Chamber in my hand
      Then I should have drawn 2 cards
      And I should need to Place a card second-from-top of deck with Secret Chamber
    When I choose Estate in my hand
      Then I should have moved Estate from hand to deck
      And I should need to Place a card on top of deck with Secret Chamber
    When I choose Estate in my hand
      Then I should have moved Estate from hand to deck
      And I should need to React to Witch
    When I choose Don't react in my hand
    And the game checks actions
      Then nothing should have happened
      And it should be Bob's Buy phase
