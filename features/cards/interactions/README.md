Card Interaction Tests
======================

This folder contains Cucumber tests for interactions of two or more cards. 

It's a somewhat hazy line where "interaction" starts - for instance, **Throne Room** + any _Duration_ card requires the **Throne Room** to remain with the _Duration_. That's not an "interaction"; it's tested under **Throne Room**'s own feature. On the other hand, **Throne Room** into **Throne Room** for two _Durations_ is an "interaction", as is **Throne Room** into a **Tactician**. As a rule of thumb, if it involves more than one _specific_ card, or is more complicated that you would expect to find in a "normal" game, it's probably an "interaction".

Please consult the wiki page [Card Interaction Tests](https://github.com/asilano/free-dom/wiki/Card-Interaction-Tests) to see what needs to be tested; and feel free to fork and contribute! 
