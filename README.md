ricer2
=====
ricer2 is an (IRC) chat-bot written in ruby (on rails). It is developed in ruby2 and RoR4.


Main Features
=============
- Global ORM Cache (ActiveRecord minimal patch with some bigger performance hit)
- Multilanguage support
- Multi network support
- Multi protocol support (irc, icq, netcat, websocket, libpurple)
- Code reload at runtime
- Threadsafe? (not tested with JRuby)
- Easy plugin creation (not really :P)
- Nice debugging and error catching
- Almost 100% plugin driven (protocols are plugins too)


Notable plugins
===============
- Rss: Manage rss feeds
- Cvs: Manage git and svn repositories (it´s a todo)
- Purple: The bot features integration with libpurple 


Future plans
============
- Plugins should be able to offer http features
- It should be possible to chain and pipe commands, like !hex abc | urlencode # => %34%31%34%32%34%33
- Default webpages for various plugins (show data, maybe rails/php/admin?)


Install guide
=============
Clone the project
> git clone https://github.com/gizmore/ricer2

Install gems
> bundle install

Edit the configuration.
> cp config/environments/development.example.rb config/environments/development.rb

> nano config/environments/development.rb

Configure your database settings
> cp config/database.example.yml config/database.yml

> nano config/database.yml

Configure some secret settings
> cp config/secrets.yml.example config/secrets.yml

> nano config/secrets.yml

Install the bot. This calls rails migrations and seed
> bundle exec rake ricer:install

Install a server/protocol/network via ricer tasks
IRC => What we love
> bundle exec rake ricer:irc[irc://irc.freenode.net:6667,ricerbot,,1]

TCP => Use, eg, netcat to talk to the bot
> bundle exec rake ricer:tcp[1,31336,0.0.0.0,ricer,1]

Websockets => yay
> bundle exec rake ricer:websocket[1,31337,0.0.0.0,ricer,1]

Violet is the libpurple connector for ICQ, Yahoo, XMPP and more
> bundle exec rake ricer:violet[icq,1,276657844,password,ricer,1]

> bundle exec rake ricer:violet[yahoo,1,guessmoor@yahoo.de,password,ricer,1]

Start the bot...  The first start takes a while, as plugins install their database tables.
> bundle exec rake ricer:start 

!Rice!Up!

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

Also change the superword.
It lifts to owner permissions, and is not totally dangerous to know, i.e.: at least no code exec.
> /msg ricer confb super superword newpassword

Make it join a channel
> /msg ricer join #somechannel


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
.... To be concluded
