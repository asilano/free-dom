free-dom/improve-testing
=======

This is a branch of the [main codebase](https://github.com/asilano/free-dom) for my free, online Dominion server.

FreeDom's tests aren't complete. The following are definitely needed:

* **Integration tests**, to automatically test the web front-end
* **Per-card unit tests**, to test that each card does what it should. Using [Cucumber](http://cukes.info). See the README under [the features/ folder][feat-code] for more information.

... and I may well be missing something else.

Note
----
Please fork and contribute to this branch - _**especially not the per-card tests**_! I need features defined for all the cards in [Intrigue][int-code], [Seaside][sea-code] and [Prosperity][pros-code]. If you want to define tests for Hinterlands cards, that would be cool too - they need to be in place before we start implementation.

[feat-code]: https://github.com/asilano/free-dom/tree/improve-testing/features
[int-code]: https://github.com/asilano/free-dom/tree/improve-testing/app/models/intrigue
[sea-code]: https://github.com/asilano/free-dom/tree/improve-testing/app/models/seaside
[pros-code]: https://github.com/asilano/free-dom/tree/improve-testing/app/models/prosperity
