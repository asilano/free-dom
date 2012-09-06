FreeDom
======

This is a branch of the codebase for my free, online Dominion server.

Notes
-----

Currently, ["master"](https://github.com/asilano/free-dom/) is the codebase as it exists on heroku.

This codebase now runs Rails 3.1, but is still using the Prototype javascript library. It's time to move on - this branch will handle the migration to jQuery.

Tasks include:
* ~~Changing all `Effect` calls to jQuery equivalents~~
* Changing all `Event` calls to jQuery equivalents
* Ensuring remote forms are implemented and handled correctly
* Updating any "loose" AJAX calls
* Updating existing .rjs files to .js.erb (I think)
* ~~Replacing TableKit with something~~

_**Please fork and contribute where possible!**_
