ricer2
=====
ricer is an IRC bot written in ruby on rails. It is developed in ruby2 and RoR4.

Main Features
=============
- Global ORM Cache (ActiveRecord patch is minimal, but with a performance hit instead gain)
- Multilanguage support
- Multi network support
- Code reloading at runtime
- Threadsafe? (not tested with JRuby)
- Easy plugin creation
- Great debugging and error catching
- Almost 100% plugin driven

Notable plugins
===============
- Rss: Manage rss feeds
- Cvs: Manage git and svn repositories (it´s a todo)
- Purple: The bot features integration with libpurple 

Future plans
============
- Plugins should be able to offer http features
- It should be possible to chain and pipe commands, like !hex abc | urlencode # => %34%31%34%32%34%33

Install guide
=============
Clone the project
> git clone https://github.com/gizmore/ricer2

Install gems
> bundle install --path vendor/bundle

Update them (skip maybe)
> bundle update

Check config/environments/development.rb for your default irc server and other stuff.
More servers can be added via irc commands later.
> nano config/environments/development.rb

Configure your database settings
> nano config/database.yml

Configure some secret settings
> cp config/secrets.yml.example config/secrets.yml
> nano config/secrets.yml

Create the database scheme
> bundle exec rake db:migrate

Fill your DB with initial values
> bundle exec rake db:seed

Start the bot...
The first start takes a while, as plugins install their databases.
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


Windows installation help
=========================
For building mysql2 gem on windows, see http://stackoverflow.com/questions/3608287/error-installing-mysql2-failed-to-build-gem-native-extension
> gem install mysql2 -- '--with-mysql-lib="c:\Program Files\MySQL\MySQL Server 5.5\lib" --with-mysql-include="c:\Program Files\MySQL\MySQL Server 5.5\include"'

For building purple_ruby on windows, ...