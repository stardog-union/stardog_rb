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

conn = Stardog::Connection.new(
  endpoint => 'http://localhost:5820',
  username => 'admin',
  password => 'admin'
)

Stardog::Server.status(conn) # => {'dbms.home' => ... }
query = 'select * where { graph <movie:starwars> { ?c a :Human } }'
Stardog::Query.execute(conn, 'db_name', query) # => {'results' => ... }
Stardog::Db::Transaction.with_transaction(conn, 'db_name') |id| do
  Stardog::Query.execute(
    conn, 'db_name',
    'insert data { :Rubber_Soul rdf:type :Album }',
    'transaction_id' => id
  )
end
```

## API

### Response

HTTP responses are parsed and the methods return the values
directly. If the server does not return a successful response, a
Stardog::Error exception is raised with the HTTP response code and
body.

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

Returns (`Hash`)

#### `Server.shutdown(conn)`

Shuts down a Stardog server.

Expects the following parameters:

- conn ([`Connection`](#connection))

Returns `:ok`.

### Db

Manage databases on the Stardog server.

#### `Db.list(conn)`

Gets a list of all databases on a Stardog server.

Expects the following parameters:

- conn ([`Connection`](#connection))

Returns (`Array<String>`)

#### `Db.create(conn, database_name, options)`

Creates a new database.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- options (`Hash`)

Returns `:ok`

#### `Db.drop(conn, database_name)`

Deletes a database.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)

Returns `:ok`

#### `Db.clear(conn, database, transaction_id, params)`

Empties the database in the specified transaction.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- params (optional `Hash`)
  Keys:
    - 'graph-uri' => the name of the graph to clear

#### `Db.online(conn, database)`

Bring a database online.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)

Returns `:ok`

#### `Db.offline(conn, database)`

Take a database offline.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)

Returns `:ok`

#### `Db.size(conn, database)`

Return the number of triples in the database.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)

Returns `Integer`

#### `Db.get_options`

Get the metadata options for a database. Option names are flattened,
eg: 'reasoning.type'.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- options (`Hash`)
  Keys are the database option names of interest. Values should be nil.

Returns (`Hash`) with the same keys and the option values filled in.

#### `Db.set_options`

Set the metadata options for a database. Option names are flattened,
eg: 'reasoning.type'.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- options (`Hash`)

Returns `:ok`

### Db::Transaction

#### Transaction.begin(conn, database)

Begin a new transaction against the database. Returns the transaction
identifier that must be used for all subsequent transactional
operations.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)

Returns (`String`)

#### Transaction.rollback(conn, database, transaction_id)

Rollback the specified transaction.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- transaction_id (`String`)

Returns `:ok`

#### Transaction.commit(conn, database, transaction_id)

Commit the specified transaction. Returns the number of records
inserted and removed.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- transaction_id (`String`)

Returns (`Hash`)

#### Transaction.with_transaction(conn, database)

Execute a block in a transaction.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)

Returns `:ok` or raises `Stardog::Error` if unable to commit

### Query

#### Query.execute(conn, database, query, params)

Execute a SPARQL query.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- query (`String`)
- params (`Hash`)
  Keys:
    - 'accept' => the desired content type of the results
    - 'transaction_id' => the transaction to execute the query inside

#### Query.add(conn, database, transaction_id, content, params)

Add data to the database in the specified transaction.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- transaction_id (`String`)
- content (`String`)
- params (`Hash`)
  Keys:
    - 'content_type' => the type of the content, defaults to 'text/turtle'
    - 'encoding' => required if the content is compressed, eg: 'gzip'

#### Query.remove(conn, database, transaction_id, content, params)

Remove data from the database in the specified transaction.

Expects the following parameters:

- conn ([`Connection`](#connection))
- database_name (`String`)
- transaction_id (`String`)
- content (`String`)
- params (`Hash`)
  Keys:
    - 'content_type' => the type of the content, defaults to 'text/turtle'
    - 'encoding' => required if the content is compressed, eg: 'gzip'

## Development

### Dependencies

After checking out the repo, run `bin/setup` to install dependencies.

### Testing

Run `rake test` to run the tests. The tests use
[VCR](https://github.com/vcr/vcr) to record the HTTP requests and
responses from the server. This repository has cassette recordings
included. To run the tests against your running Stardog server, remove
the cassette files in `test/cassettes`. **WARNING: running the tests
without the cassettes will remove the database named 'test_db' if
present.** Without the cassettes, tests that happen to run after the
server shutdown test will fail. Start the stardog server back up and
restart the tests. The cassette for the shutdown test will be used and
they should all pass.

### Console
Run `bin/console` for an interactive prompt that will allow you to experiment.

### Packaging

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in
`version.rb`, and then run `bundle exec rake release`, which will
create a git tag for the version, push git commits and tags, and push
the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/stardog-union/stardog_rb.
