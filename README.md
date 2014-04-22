# Tournament Director

Tournament Director is an app for running quizbowl tournaments.

## Features

- Tracks statistics!
- Supports multi-user entry!

## Lacking features

- Anything beyond statistics

## Installation (basic)

Tournament Director is a [CouchApp](http://docs.couchdb.org/en/latest/couchapp) written in [CoffeeScript](http://coffeescript.org) with [Bootstrap](http://getbootstrap.com).

To install and run it locally, the distribution includes a configuration file for working with [Vagrant](http://www.vagrantup.com), which is a generally good practice for server development. Once you have Vagrant installed and running, simply run `vagrant up` from the project's root level.

You'll want to make an extra entry in [your system's `hosts` file][1] pointing the host `td` to `127.0.0.1` so you can use Tournament Director's own URLs.

After doing both of those things, open [http://td:5444](http://td:5444) in your browser and you'll see sample data.

To get a shell inside your virtual machine, run `vagrant ssh`.

To compile your latest code and upload it to the database, run `grunt` from within the aforementioned shell.

## Installation (advanced)

You can certainly install CouchDB on your own machine and have Node and Grunt running locally.

The Gruntfile has two major commands:
- The default command compiles the whole app and uploads it to the database specified in `scripts/database.coffee`.
- The `generate` command both runs the default command and generates an HSNCT-sized tournament's worth of data.

[1]: http://en.wikipedia.org/wiki/Hosts_(file)