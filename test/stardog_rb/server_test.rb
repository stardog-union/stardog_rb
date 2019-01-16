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
    # see if a couple of the expected values are in the response
    assert response.key?('dbms.home')
    assert response.key?('system.uptime')
  end

  def test_server_shutdown
    response = Stardog::Server.shutdown(@conn)
    assert response == :ok
  end
end
