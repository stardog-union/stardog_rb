require 'json'
require 'test_helper'
require 'stardog_rb'

class DbTest < Minitest::Test
  Db = Stardog::Db
  Transaction = Stardog::Db::Transaction

  def setup
    @conn = Stardog::Connection.new
    VCR.insert_cassette name
  end

  def teardown
    VCR.eject_cassette
  end

  def fixture_file(file_name)
    File.new(File.expand_path("../../fixtures/#{file_name}", __dir__))
  end

  def test_db_list
    response = Db.list(@conn)
    response_json = JSON.parse(response.body)
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert response_json.key?('databases')
  end

  def test_db_create
    response = Db.create(@conn, 'test_db')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '201'
    assert response.content_type == 'application/json'
    assert message.start_with?('Successfully created database')
  end

  def test_db_create_with_options
    options = { 'reasoning.type' => 'DL' }
    response = Db.create(@conn, 'test_db', options)
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '201'
    assert response.content_type == 'application/json'
    assert message.start_with?('Successfully created database')
  end

  def test_db_create_with_files
    response = Db.create(
      @conn, 'test_db',
      { 'reasoning.type' => 'RDFS' },
      [fixture_file('beatles.ttl'), ''],
      [fixture_file('starwars.ttl.gz'), 'movie:starwars']
    )
    assert response.code == '201'
    assert response.content_type == 'application/json'
    assert JSON.parse(response.body)['message'] =~ /Successfully/
  end

  def test_db_drop
    response = Db.drop(@conn, 'test_db')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert message.end_with?('was successfully dropped.')
  end

  def test_db_clear
    assert Db.size(@conn, 'test_db').body == '1'
    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Db.clear(@conn, 'test_db', transaction_id)
    end
    assert Db.size(@conn, 'test_db').body == '0'
  end

  def test_db_size
    response = Db.size(@conn, 'test_db')
    puts response.body
    assert response.code == '200'
    assert response.body == '1'
  end

  def test_db_online
    response = Db.online(@conn, 'test_db')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert message.end_with?('was successfully brought online')
  end

  def test_db_offline
    response = Db.offline(@conn, 'test_db')
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
    response = Db.set_options(@conn, 'test_db', options)
    assert response.code == '200'
    assert response.body =~ /option.*were successfully set/
  end

  def test_db_get_options
    options = {
      'search.enabled' => nil,
      'reasoning.type' => nil
    }
    response = Db.get_options(@conn, 'test_db', options)
    response_json = JSON.parse(response.body)
    assert response.code == '200'
    assert response_json.key? 'search.enabled'
    assert response_json.key? 'reasoning.type'
    refute response_json.key? 'database.online'
  end
end
