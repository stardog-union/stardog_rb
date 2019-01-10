require 'json'
require 'test_helper'
require 'stardog_rb'

class DbTest < Minitest::Test
  def setup
    @conn = StardogRb::Connection.new
    VCR.insert_cassette name
  end

  def teardown
    VCR.eject_cassette
  end

  def test_db_list
    response = StardogRb::Db::Db.list(@conn)
    response_json = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert response_json.key?('databases')
  end

  def test_db_create
    response = StardogRb::Db::Db.create(@conn, 'beatles')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '201'
    assert response.content_type == 'application/json'
    assert message.start_with?('Successfully created database')
  end

  # def test_create_db_with_options
  #   assert false
  # end

  def test_db_drop
    response = StardogRb::Db::Db.drop(@conn, 'beatles')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert message.end_with?('was successfully dropped.')
  end

  def test_db_online
    response = StardogRb::Db::Db.online(@conn, 'beatles')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert message.end_with?('was successfully brought online')
  end

  def test_db_offline
    response = StardogRb::Db::Db.offline(@conn, 'beatles')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert message.end_with?('was successfully set offline.')
  end

  def test_db_set_options
    options = {
      'search.enabled' => true,
      'reasoning.type' => 'DL'
    }
    response = StardogRb::Db::Db.set_options(@conn, 'beatles', options)
    assert response.code == '200'
    assert response.body =~ /option.*were successfully set/
  end

  def test_db_get_options
    options = {
      'search.enabled' => nil,
      'reasoning.type' => nil
    }
    response = StardogRb::Db::Db.get_options(@conn, 'beatles', options)
    response_json = JSON.parse(response.body)
    assert response.code == '200'
    assert response_json.key? 'search.enabled'
    assert response_json.key? 'reasoning.type'
    refute response_json.key? 'database.online'
  end
end
