require 'test_helper'
require 'stardog_rb'

class QueryTest < Minitest::Test
  def setup
    @conn = StardogRb::Connection.new
    VCR.insert_cassette name
  end

  def teardown
    VCR.eject_cassette
  end

  def test_select_query
    query = 'select * { ?album a :Album . }'
    response = StardogRb::Query.execute(@conn, 'test_db', query)
    json_response = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type == 'application/sparql-results+json'
    assert json_response['results']['bindings'].length == 3
  end

  def test_select_with_named_graph
    query = 'select * where { graph <movie:starwars> { ?c a :Human } }'
    response = StardogRb::Query.execute(@conn, 'test_db', query)
    json_response = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type == 'application/sparql-results+json'
    assert json_response['results']['bindings'].length == 5
  end

  def test_specify_content_accept
    query = 'construct where { ?s ?p ?o }'
    response = StardogRb::Query.execute(
      @conn, 'test_db', query, 'accept' => 'application/ld+json'
    )
    assert response.code == '200'
    assert response.content_type == 'application/ld+json'
  end

  def test_ask_query_true
    query = 'ask { graph <movie:starwars> {:luke a :Human }}'
    response = StardogRb::Query.execute(@conn, 'test_db', query)
    assert response.code == '200'
    assert response.content_type == 'text/boolean'
    assert response.body == 'true'
  end

  def test_ask_query_false
    query = 'ask { graph <movie:starwars> {:luke a :Droid }}'
    response = StardogRb::Query.execute(@conn, 'test_db', query)
    assert response.code == '200'
    assert response.content_type == 'text/boolean'
    assert response.body == 'false'
  end
end
