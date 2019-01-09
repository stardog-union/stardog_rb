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
    query = 'select * {?album a :Album .}'
    response = StardogRb::Query.execute(@conn, 'beatles', query)
    json_response = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type == 'application/sparql-results+json'
    assert json_response['results']['bindings'].length == 3
  end
end
