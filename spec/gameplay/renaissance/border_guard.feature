# Action (cost: 2) - +1 Action. Reveal the top 2 cards of your deck. Put one into your hand and discard the other. If both were Actions, take the Lantern or Horn.
# Horn - Once per turn, when you discard a Border Guard from play, you may put it onto your deck.
# Lantern - Border Guards you play reveal 3 cards and discard 2. (It takes all 3 being Actions to take the Horn.)
Feature: Border Guard
  Background:
    Given I am in a 3 player game
    And my hand contains Border Guard, Border Guard, Estate, Copper, Silver
    And the kingdom choice contains Border Guard

  Scenario Outline: Playing Border Guard - stop before artifact choice
    And my deck contains <deck>
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should move as follows:
      Then I should reveal <count> cards from my deck
      And these card moves should happen
    And I should need to 'Choose a card to put into your hand'
    When I choose <hand_card> in my revealed cards
    Then cards should move as follows:
      Then I should move <hand_card> from my deck to my hand
      And I should discard <discard_card> from my deck
      And these card moves should happen
    And I should need to <next_question>
    Examples:
      | deck                  | count | hand_card        | discard_card | next_question             |
      | Gold, Copper, Village |   2   | Gold             | Copper       | 'Play an Action, or pass' |
      | Gold, Copper, Village |   2   | Copper           | Gold         | 'Play an Action, or pass' |
      | Gold                  |   1   | Gold             | nothing      | 'Play an Action, or pass' |
      | Village, Market, Gold |   2   | Market           | Village      | 'Take Lantern or Horn'    |

  Scenario Outline: Playing Border Guard - take an Artifact
    And my deck contains Village, Market, Gold
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should move as follows:
      Then I should reveal 2 cards from my deck
      And these card moves should happen
    And I should need to 'Choose a card to put into your hand'
    When I choose Village in my revealed cards
    Then cards should move as follows:
      Then I should move Village from my deck to my hand
      And I should discard Market from my deck
      And these card moves should happen
    And I should need to 'Take Lantern or Horn'
    When I choose the option <choice>
    Then I should have the <chosen>
    And I should not have the <unchosen>
    Examples:
      | choice             | chosen  | unchosen |
      | 'Take the Horn'    | Horn    | Lantern  |
      | 'Take the Lantern' | Lantern | Horn     |

  Scenario: Playing Border Guard - empty deck
    And my deck contains nothing
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should not move
    And I should need to 'Choose a card to put into your hand'
    When I choose 'Choose nothing' in my revealed cards
    Then cards should not move
    And I should need to 'Play an Action, or pass'

  Scenario: Playing Border Guard with Horn - put discard on deck
    And my deck contains nothing
    And I have the Horn
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should not move
    And I should need to 'Choose a card to put into your hand'
    When I choose 'Choose nothing' in my revealed cards
    Then cards should not move
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from play
      And these card moves should happen
    Then I should need to "Place Border Guard on your deck?"
    When I choose Border Guard in my discard
    Then cards should move as follows:
      Then I should move Border Guard from my discard to my deck
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"

  Scenario: Playing Border Guard with Horn - decline to keep discard
    And my deck contains nothing
    And I have the Horn
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should not move
    And I should need to 'Choose a card to put into your hand'
    When I choose 'Choose nothing' in my revealed cards
    Then cards should not move
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from play
      And these card moves should happen
    Then I should need to "Place Border Guard on your deck?"
    When I choose "Leave in discard" in my discard
    Then cards should move as follows:
      Then I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"

  Scenario: Playing Border Guard twice with Horn - check can keep only 1
    And my deck contains nothing
    And I have the Horn
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should not move
    And I should need to 'Choose a card to put into your hand'
    When I choose 'Choose nothing' in my revealed cards
    Then cards should not move
    And I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should not move
    And I should need to 'Choose a card to put into your hand'
    When I choose 'Choose nothing' in my revealed cards
    Then cards should not move
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from play
      And these card moves should happen
    Then I should need to "Place Border Guard on your deck?"
    When I choose Border Guard in my discard
    Then cards should move as follows:
      Then I should move Border Guard from my discard to my deck
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"

  Scenario: Playing Border Guard twice with Horn - check can keep second one
    And my deck contains nothing
    And I have the Horn
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should not move
    And I should need to 'Choose a card to put into your hand'
    When I choose 'Choose nothing' in my revealed cards
    Then cards should not move
    And I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should not move
    And I should need to 'Choose a card to put into your hand'
    When I choose 'Choose nothing' in my revealed cards
    Then cards should not move
    And I should need to 'Play an Action, or pass'
    When I choose "Leave Action Phase" in my hand
    Then I should need to "Play Treasures, or pass"
    When I choose 'Stop playing treasures' in my hand
    Then I should need to "Buy a card, or pass"
    When I choose "Buy nothing" in the supply
    Then cards should move as follows:
      And I should discard everything from my hand
      And I should discard everything from play
      And these card moves should happen
    Then I should need to "Place Border Guard on your deck?"
    When I choose "Leave in discard" in my discard
    Then I should need to "Place Border Guard on your deck?"
    When I choose Border Guard in my discard
    Then cards should move as follows:
      Then I should move Border Guard from my discard to my deck
      And I should draw 5 cards
      And these card moves should happen
    And Belle should need to "Play an Action, or pass"


  Scenario: Playing Border Guard with Horn - take Lantern
    And my deck contains Village, Market, Gold
    And I have the Horn
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should move as follows:
      Then I should reveal 2 cards from my deck
      And these card moves should happen
    And I should need to 'Choose a card to put into your hand'
    When I choose Village in my revealed cards
    Then cards should move as follows:
      Then I should move Village from my deck to my hand
      And I should discard Market from my deck
      And these card moves should happen
    And I should need to 'Take Lantern or Horn'
    When I choose the option 'Take the Lantern'
    Then I should have the Lantern
    And I should have the Horn

  Scenario: Playing Border Guard with Horn - take Horn again
    And my deck contains Village, Market, Gold
    And I have the Horn
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should move as follows:
      Then I should reveal 2 cards from my deck
      And these card moves should happen
    And I should need to 'Choose a card to put into your hand'
    When I choose Village in my revealed cards
    Then cards should move as follows:
      Then I should move Village from my deck to my hand
      And I should discard Market from my deck
      And these card moves should happen
    And I should need to 'Take Lantern or Horn'
    When I choose the option 'Take the Horn'
    Then I should not have the Lantern
    And I should have the Horn

  Scenario: Playing Border Guard with Lantern
    And my deck contains <deck>
    And I have the Lantern
    Then I should need to 'Play an Action, or pass'
    When I choose Border Guard in my hand
    Then cards should move as follows:
      Then I should reveal <count> cards from my deck
      And these card moves should happen
    And I should need to 'Choose a card to put into your hand'
    When I choose <hand_card> in my revealed cards
    Then cards should move as follows:
      Then I should move <hand_card> from my deck to my hand
      And I should discard <discard_cards> from my deck
      And these card moves should happen
    And I should need to <next_question>
    Examples:
      | deck                  | count | hand_card        | discard_card    | next_question             |
      | Gold, Copper, Village |   3   | Gold             | Copper, Village | 'Play an Action, or pass' |
      | Gold, Copper, Village |   3   | Copper           | Gold, Village   | 'Play an Action, or pass' |
      | Village, Market       |   2   | Village          | Market          | 'Play an Action, or pass' |
      | Village, Market, Mine |   3   | Market           | Village, Mine   | 'Take Lantern or Horn'    |
      | Village, Market, Gold |   3   | Market           | Village, Gold   | 'Play an Action, or pass' |
