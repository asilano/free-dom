Cucumber tests
==============

This folder and its subfolders contain Cucumber features for each card. When adding cards to the game, please follow **Test Driven Development** - add a Cucumber feature for the card _before_ you start coding the card itself!

Features in this folder are all subject to an **AfterStep** hook - after each step, the Cucumber instance variable `@hand_contents[name]` (which is an Array of unprefixed card names, like `"Gold"` or `"Smithy"` - `@hand_contents` itself is a Hash from player names to these arrays) is verified as having the same contents (in any order) as `player.cards.hand.map(&:readable_name)`, where `player` is the `Player` whose `User` has the name `name`. Similar checks are done for `play`, `discard` and `enduring`; `deck` is also checked, but additionally must be in the same order.

Expected outcomes of playing cards should therefore be described in terms of the movement of the cards. For instance, Smithy's feature contains the step `I should have drawn 3 cards`. The corresponding step definition simply adjusts `@hand_contents` and `@deck_contents` (plus `@discard_contents` if required) to reflect in the test-bed the action of drawing three cards.

The following points should therefore be noted:

* In order that we can correctly predict the result of shuffling a discard pile, `Array#shuffle` has been redefined to call `Array#sort`; and `Card` has defined `<=>` to compare two card's `readable_name`s. Therefore, when discards are "shuffled", the result is that the cards are in alphabetical order by unprefixed name.
* Certain steps suppress the checking of cards after themselves. These are steps where we would usually expect something to change as a result of the step; for instance `When I play Smithy` suppresses checking, since we know that playing an Action card is likely to adjust the cards in each zone. The expected changes should then follow in the feature
* Sometimes, more than one change needs to happen at once. For instance, playing Cellar results in some cards being discarded, and then some cards being drawn. These effects happen without pause, so checking the card state after the discard but before the draw would fail. For this reason, we have the `Then the following <number> steps should happen at once` step, which suppresses checking of card locations until after the specified number of steps have completed.