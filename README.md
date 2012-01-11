FreeDom
=======

This is the codebase for my free, online Dominion server.

Notes
-----

Currently, this is the codebase as it exists locally, for dev purposes. It is now the same branch on my (again, local) Subversion repository as the one I push to heroku, but this codebase has not yet been pushed.

This codebase now runs Rails 3.1, but is still using the Prototype javascript library. It's time to move on - I'll be migrating to jQuery in my next release (which will mainly be to implement Hinterlands). However, the trickiest work - migrating to Rails 3.1 - is done. I'll be pushing this to a staging app soon for verification, and then sending it live.

Once this is live, I'll open it up for outside contributions. I'll be creating branches for:

* Migration to jQuery
* Implementation of Hinterlands
* Per-card unit tests (likely using [Cucumber](http://cukes.info/), and general test improvements including integration tests

Additional features possibly up for implementation include:

* Structural "bug fixes" that aren't fatal, but are large. Such as occasional loss of transactional integrity
* Richer set of random-game options, a la [this randomiser](http://www.hiwiller.com/dominion/)
* Front-end restyling
* Ratings history
