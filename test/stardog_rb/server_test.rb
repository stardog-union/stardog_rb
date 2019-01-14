require 'json'
require 'test_helper'
require 'stardog_rb'

class ServerTest < Minitest::Test
  def setup
    @conn = Stardog::Connection.new
    VCR.insert_cassette name
  end

  def teardown
    VCR.eject_cassette
  end

  def test_that_it_retrieves_the_server_status
    response = Stardog::Server.status(@conn)
    response_json = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type = 'application/json'
    # see if a couple of the expected values are in the response
    assert response_json.key?('dbms.home')
    assert response_json.key?('system.uptime')
  end

  def test_server_shutdown
    response = Stardog::Server.shutdown(@conn)
    assert response.code == '200'
  end
end
