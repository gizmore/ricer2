ricer2
=====
ricer is an IRC bot written in ruby on rails. It is developed in ruby2 and RoR4.

Main Features
=============
- Global ORM Cache (ActiveRecord patch is minimal without performance gain)
- Multilanguage support
- Multi network support
- Code reloading at runtime
- Threadsafe
- Easy plugin creation
- Great debugging and error catching
- Almost 100% plugin driven

Notable plugins
===============
- Cvs - Manage git and svn repositories
- Rss - Manage rss feeds


Future plans
============
- Plugins should be able to offer http features
- It should be possible to add servers via a rake task 

Install guide
=============
Clone the project
> git clone https://github.com/gizmore/ricer2

Install gems
> bundle install --path vendor/bundle

Update them (skip maybe)
> bundle update

Configure your database
> bundle exec rake db:migrate

Check db/seed.rb for creating your first server.
More servers can be added via irc later.
> bundle exec rake db:seed

Start the bot...
> bundle exec rake ricer:start

...but it will currently fail on first dry run, but a second start fixes it.
> bundle exec rake ricer:start

Rice Up!

Usage guide
===========
Test if the bot responses to "ping".
> /msg ricer ping

You should now register yourself.
> /msg ricer register password

Elevate your priviledges
> /msg ricer super chickencurry

Change this powerful password
> /msg ricer confb super magicword newpassword

Also change the superword (it lifts to owner permissions, and is not really dangerous to know, i.e. no code exec)
> /msg ricer confb super superword newpassword

Make it join a channel
> /msg ricer join #somechannel

Lift your priviledges there too
> /msg ricer super newpassword


What now
========
Ricer has a configurable trigger char for each channel / server.
Default is currently ','
So you need to type ',ping' in a channel.


Known Bugs
==========
- Usage message is not correct (multi usage plugins)
- Usage does not nicely know when it should be shown (multi usage plugins)
- The send penalty queue has not receiver as queue, but sender. This is a problem for pastebin queueflush :(
