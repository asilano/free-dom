FreeDom
=======

This is the codebase for my free, online Dominion server.

Notes
-----

Currently, "master" is the codebase as it exists on heroku.

This codebase now runs Rails 3.1, but is still using the Prototype javascript library. It's time to move on - I'll be migrating to jQuery in my next release (which will mainly be to implement Hinterlands). However, the trickiest work - migrating to Rails 3.1 - is done.

This codebase is now open for outside contributions in certain areas. Branches exist or will be created for:

* [Migration to jQuery](https://github.com/asilano/free-dom/tree/prototype-to-jquery)
* [General test improvements](https://github.com/asilano/free-dom/tree/improve_testing) including integration tests and per-card unit tests (likely using [Cucumber](http://cukes.info/)
* Implementation of Hinterlands _(deferred until the Cucumber test framework is in place)_

Additional features possibly up for implementation include:

* Structural "bug fixes" that aren't fatal, but are large. Such as occasional loss of transactional integrity
* Richer set of random-game options, a la [this randomiser](http://www.hiwiller.com/dominion/)
* Front-end restyling
* Ratings history

_**Please fork and contribute where possible!**_