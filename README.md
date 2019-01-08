# Stardog_rb

Licensed under the
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

Stardog_rb: Ruby bindings to use to develop apps with the
[Stardog Graph / RDF Database](http://stardog.com).

![Stardog](http://stardog.com/img/stardog.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stardog_rb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stardog_rb

## Quick Example

``` ruby
require 'stardog_rb'

conn = StardogRb::Connection.new(
  endpoint => 'http://localhost:5820',
  username => 'admin',
  password => 'admin'
)

StardogRb::Server.status(conn)
```

## API

### Response

Functions that make an HTTP request return a [`Net::HTTPResponse`](https://ruby-doc.org/stdlib-2.5.3/libdoc/net/http/rdoc/Net/HTTPResponse.html)

### Connection

Holds the connection information for the Stardog server.

Constructed with:

- endpoint (`String`)
- username (`String`)
- password (`String`)

### Server

#### `Server.status(conn)`

Retrieves general status information about a Stardog server.

Expects the following parameters:

- conn ([`Connection`](#connection))

Returns a [`Net::HTTPResponse`](#response)

#### `Server.shutdown(conn)`

Shuts down a Stardog server.

Expects the following parameters:

- conn ([`Connection`](#connection))

Returns a [`Net::HTTPResponse`](#response)

### Db::Db

Manage databases on the Stardog server.

#### `Db.list(conn)`

Gets a list of all databases on a Stardog server.

Expects the following parameters:

- conn ([`Connection`](#connection))

Returns a [`Net::HTTPResponse`](#response)

#### `Db.create(conn, database_name, options)`

Creates a new database.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- options (`Hash`)

Returns a [`Net::HTTPResponse`](#response)

#### `Db.drop(conn, database_name)`

Deletes a database.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)

Returns a [`Net::HTTPResponse`](#response)

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rake test` to run the tests. You can also run
`bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/stardog-union/stardog_rb.
