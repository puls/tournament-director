Tournament Director
===================

Tournament Director is an app for running quizbowl tournaments.

Features
--------

-   Tracks statistics!
-   Supports multi-user entry!

Lacking features
----------------

-   Anything beyond statistics

Installation
------------

Tournament Director is a
[CouchApp](http://docs.couchdb.org/en/latest/couchapp) written in
[CoffeeScript](http://coffeescript.org) with
[Ember](http://emberjs.com), [Emblem](http://emblemjs.com), and
[Bootstrap](http://getbootstrap.com). Its build system is
[Grunt](http://gruntjs.com).

### In the cloud

You can get a fully-functioning installation of Tournament Director by
visiting http://www.tournamentdirector.org and signing up. It's free!

### Mac

You're using [Homebrew](http://brew.sh)? Great! Install
[CouchDB](http://couchdb.apache.org) and [Node](http://nodejs.org):

    brew install couchdb node

Install the right Node modules to run the build system:

    npm install -g grunt-cli bower local-tld
    npm install

Configure and start CouchDB:

    cp scripts/couchdb.ini /usr/local/etc/couchdb/local.ini
    couchdb &

Build Tournament Director and generate some test data:

    grunt generate
    open 'http://qbtd.couchdb.dev'

### Other systems

You can follow similar steps to the above by installing
[CouchDB](http://couchdb.apache.org) and [Node](http://nodejs.org)
following their own instructions for your platform.

Note that `local-tld` is only available on the Mac, so you'll need to
make an extra entry in [your system's `hosts`
file](http://en.wikipedia.org/wiki/Hosts_%28file%29) pointing the host
`qbtd.couchdb.dev` to `127.0.0.1` so you can use Tournament Director's
own URLs and add the port number to the URL where you access Tournament
Director, namely `http://qbtd.couchdb.dev:5984`.

### Vagrant

The distribution includes a configuration file for working with
[Vagrant](http://www.vagrantup.com), which is a generally good practice
for server development. Once you have Vagrant installed and running,
simply run `vagrant up` from the project's root level.

You'll want to make an extra entry in [your system's `hosts`
file](http://en.wikipedia.org/wiki/Hosts_%28file%29) pointing the host
`qbtd.couchdb.dev` to `127.0.0.1` so you can use Tournament Director's
own URLs.

After doing both of those things, open <http://qbtd.couchdb.dev:5444> in
your browser and you'll see sample data. (Note that the port here is
5444 instead of 5984 as elsewhere, since Vagrant is forwarding port 5444
on the host to port 5984 on the guest.)

To get a shell inside your virtual machine, run `vagrant ssh`.

To compile your latest code and upload it to the database, run `grunt`
from within the aforementioned shell.

Command-line usage
------------------

The Gruntfile has two major commands:

-   The default command (`grunt`) compiles the whole app and uploads it
    to the database specified in `scripts/database.coffee`.

-   The "generate" command (`grunt generate`) both runs the default
    command and generates an HSNCT-sized tournament's worth of data.
