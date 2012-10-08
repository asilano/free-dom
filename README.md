FreeDom
======

This is a branch of the codebase for my free, online Dominion server.

Notes
-----

Currently, ["master"](https://github.com/asilano/free-dom/) is the codebase as it exists on heroku.

This codebase now runs Rails 3.1, but is still using the Prototype javascript library. It's time to move on - this branch will handle the migration to jQuery.

Tasks include:
* ~~Changing all `Effect` calls to jQuery equivalents~~
* ~~Changing all `Event` calls to jQuery equivalents~~
* ~~Ensuring remote forms are implemented and handled correctly~~
* ~~Updating any "loose" AJAX calls~~
* ~~Updating existing .rjs files to .js.erb (I think)~~
* ~~Replacing TableKit with something~~
* Making any "loose" (without form) AJAX calls have non-JS versions (player settings per game only example?)
* Updating supported browsers. IE is out, unless I can find a good shim.
* ~~Fix chat updating so it updates.~~
* Fix start game button so it appears automatically (if possible)
* ~~Check controls on Revealed / Peeked cards work~~

_**Please fork and contribute where possible!**_
