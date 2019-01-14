require 'test_helper'
require 'stardog_rb'

class QueryTest < Minitest::Test
  def setup
    @conn = Stardog::Connection.new
    VCR.insert_cassette name
  end

  def teardown
    VCR.eject_cassette
  end

  def test_select_query
    query = 'select * { ?album a :Album . }'
    response = Stardog::Query.execute(@conn, 'test_db', query)
    json_response = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type == 'application/sparql-results+json'
    assert json_response['results']['bindings'].length == 3
  end

  def test_select_with_named_graph
    query = 'select * where { graph <movie:starwars> { ?c a :Human } }'
    response = Stardog::Query.execute(@conn, 'test_db', query)
    json_response = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type == 'application/sparql-results+json'
    assert json_response['results']['bindings'].length == 5
  end

  def test_specify_content_accept
    query = 'construct where { ?s ?p ?o }'
    response = Stardog::Query.execute(
      @conn, 'test_db', query, 'accept' => 'application/ld+json'
    )
    assert response.code == '200'
    assert response.content_type == 'application/ld+json'
  end

  def test_query_limit_param
    query = 'select * where { graph <movie:starwars> { ?c a :Human } }'
    response = Stardog::Query.execute(@conn, 'test_db', query, 'limit' => 3)
    json_response = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type == 'application/sparql-results+json'
    assert json_response['results']['bindings'].length == 3
  end

  def test_ask_query_true
    query = 'ask { graph <movie:starwars> {:luke a :Human }}'
    response = Stardog::Query.execute(@conn, 'test_db', query)
    assert response.code == '200'
    assert response.content_type == 'text/boolean'
    assert response.body == 'true'
  end

  def test_ask_query_false
    query = 'ask { graph <movie:starwars> {:luke a :Droid }}'
    response = Stardog::Query.execute(@conn, 'test_db', query)
    assert response.code == '200'
    assert response.content_type == 'text/boolean'
    assert response.body == 'false'
  end

  def test_construct_query
    query = 'construct where { ?s ?p ?o }'
    response = Stardog::Query.execute(@conn, 'test_db', query)
    assert response.code == '200'
    assert response.content_type == 'text/turtle'
  end

  def test_insert_query
    query = 'insert data { :foo :bar :baz }'
    response = Stardog::Query.execute(@conn, 'test_db', query)
    assert response.code == '200'
    select_q = 'select * { :foo ?p ?o }'
    response = Stardog::Query.execute(@conn, 'test_db', select_q)
    json_response = JSON.parse(response.body)
    assert json_response['results']['bindings'].length == 1
  end
end
