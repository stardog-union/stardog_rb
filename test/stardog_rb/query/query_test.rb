require 'test_helper'
require 'stardog_rb'

class QueryTest < Minitest::Test
  Query = Stardog::Query
  Transaction = Stardog::Db::Transaction

  TRIPLE = %(
        <http://localhost/publications/articles/Journal1/1940/Article2>
        <http://purl.org/dc/elements/1.1/subject>
        "Very interesting subject"^^<http://www.w3.org/2001/XMLSchema#string> .
    ).freeze

  def setup_db(conn)
    without_vcr do
      drop_test_db(conn)
      Stardog::Db.create(
        conn, 'test_db', {},
        [fixture_file('beatles.ttl'), ''],
        [fixture_file('starwars.ttl.gz'), 'movie:starwars']
      )
    end
  end

  def setup
    @conn = Stardog::Connection.new
    setup_db(@conn)

    if name.include?('compressed')
      VCR.insert_cassette(name, preserve_exact_body_bytes: true)
    else
      VCR.insert_cassette name
    end
  end

  def teardown
    VCR.eject_cassette
  end

  def in_db?(triple, params = {})
    name = params.delete('name')
    query = if name
              "ask where { graph <#{name}> { #{triple} } }"
            else
              "ask where { #{triple} }"
            end
    Query.execute(@conn, 'test_db', query, params) # ask returns bool
  end

  def test_select_query
    query = 'select * { ?album a :Album . }'
    response = Query.execute(@conn, 'test_db', query)
    assert response['results']['bindings'].length == 3
  end

  def test_select_with_named_graph
    query = 'select * where { graph <movie:starwars> { ?c a :Human } }'
    response = Query.execute(@conn, 'test_db', query)
    assert response['results']['bindings'].length == 5
  end

  def test_specify_content_accept
    query = 'construct where { ?s ?p ?o }'
    response = Query.execute(
      @conn, 'test_db', query, 'accept' => 'application/ld+json'
    )
    assert response.is_a?(Array)
  end

  def test_query_limit_param
    query = 'select * where { graph <movie:starwars> { ?c a :Human } }'
    response = Query.execute(@conn, 'test_db', query, 'limit' => 3)
    assert response['results']['bindings'].length == 3
  end

  def test_ask_query_true
    query = 'ask { graph <movie:starwars> {:luke a :Human }}'
    response = Query.execute(@conn, 'test_db', query)
    assert response == true
  end

  def test_ask_query_false
    query = 'ask { graph <movie:starwars> {:luke a :Droid }}'
    response = Query.execute(@conn, 'test_db', query)
    assert response == false
  end

  def test_construct_query
    query = 'construct where { ?s ?p ?o }'
    response = Query.execute(@conn, 'test_db', query)
    assert response.include?('<http://api.stardog.com/The_Beatles>')
  end

  def test_insert_query
    query = 'insert data { :foo :bar :baz }'
    response = Query.execute(@conn, 'test_db', query)
    assert response == :ok
    select_q = 'select * { :foo ?p ?o }'
    select_response = Query.execute(@conn, 'test_db', select_q)
    assert select_response['results']['bindings'].length == 1
  end

  def test_add_triple_in_transaction_and_commit
    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.add(@conn, 'test_db', transaction_id, TRIPLE)
    end

    assert in_db?(TRIPLE)
  end

  def test_add_triple_in_transaction_and_rollback
    transaction_id = Transaction.begin(@conn, 'test_db')
    Query.add(@conn, 'test_db', transaction_id, TRIPLE)
    refute in_db?(TRIPLE) # transaction in progress
    Transaction.rollback(@conn, 'test_db', transaction_id)
    refute in_db?(TRIPLE)
  end

  def test_remove_triple_in_transaction_and_commit
    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.add(@conn, 'test_db', transaction_id, TRIPLE)
    end

    assert in_db?(TRIPLE)

    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.remove(@conn, 'test_db', transaction_id, TRIPLE)
    end

    refute in_db?(TRIPLE)
  end

  def test_add_named_graph
    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.add(
        @conn, 'test_db', transaction_id, TRIPLE, 'graph-uri' => 'stardog:test'
      )
    end

    refute in_db?(TRIPLE) # must specify graph name
    assert in_db?(TRIPLE, 'name' => 'stardog:test')
  end

  def test_remove_named_graph
    Transaction.with_transaction(@conn, 'test_db') do |t_id|
      Query.add(@conn, 'test_db', t_id, TRIPLE, 'graph-uri' => 'sd:test')
    end
    assert in_db?(TRIPLE, 'name' => 'sd:test')

    Transaction.with_transaction(@conn, 'test_db') do |t_id|
      Query.remove(@conn, 'test_db', t_id, TRIPLE, 'graph-uri' => 'sd:test')
    end
    refute in_db?(TRIPLE, 'name' => 'sd:test')
  end

  def test_add_triple_from_file
    file = fixture_file('simple_test.ttl')

    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.add(@conn, 'test_db', transaction_id, file.read)
    end

    assert in_db?(TRIPLE)
  end

  def test_add_triple_from_compressed_file
    file = fixture_file('simple_test.ttl.gz')

    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.add(
        @conn, 'test_db', transaction_id, file.read, 'encoding' => 'gzip'
      )
    end

    assert in_db?(TRIPLE)
  end

  def test_remove_triple_from_file
    file_contents = fixture_file('simple_test.ttl').read

    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.add(@conn, 'test_db', transaction_id, file_contents)
    end

    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.remove(@conn, 'test_db', transaction_id, file_contents)
    end

    refute in_db?(TRIPLE)
  end

  def test_remove_triple_from_compressed_file
    file_contents = fixture_file('simple_test.ttl.gz').read

    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.add(
        @conn, 'test_db', transaction_id, file_contents, 'encoding' => 'gzip'
      )
    end

    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.remove(
        @conn, 'test_db', transaction_id, file_contents, 'encoding' => 'gzip'
      )
    end

    refute in_db?(TRIPLE)
  end

  def test_select_in_transaction
    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      response = Query.execute(
        @conn, 'test_db', 'select * { ?album a :Album . }',
        'transaction_id' => transaction_id
      )
      assert response['results']['bindings'].length == 3
    end
  end

  def test_insert_in_transaction
    rubber_soul = '{ :Rubber_Soul rdf:type :Album }'
    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Query.execute(
        @conn, 'test_db', "insert data #{rubber_soul}",
        'transaction_id' => transaction_id
      )
      assert in_db?(rubber_soul, 'transaction_id' => transaction_id) # inside
      refute in_db?(rubber_soul) # not committed yet to outside world
    end
    assert in_db?(rubber_soul)
  end
end
