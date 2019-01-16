require 'json'
require 'test_helper'
require 'stardog_rb'

class DbTest < Minitest::Test
  Db = Stardog::Db
  Transaction = Stardog::Db::Transaction

  def prepare_db_without_vcr
    VCR.configure do |c|
      c.allow_http_connections_when_no_cassette = true
      Stardog::Db.drop(@conn, 'test_db')
      c.allow_http_connections_when_no_cassette = false
    end
  end

  def setup
    @conn = Stardog::Connection.new
    prepare_db_without_vcr

    if name.include?('compressed')
      VCR.insert_cassette(name, preserve_exact_body_bytes: true)
    else
      VCR.insert_cassette name
    end
  end

  def teardown
    VCR.eject_cassette
  end

  def test_db_list
    empty = Db.list(@conn)
    assert empty.empty?
    Db.create(@conn, 'test_db')
    list = Db.list(@conn)
    assert list.size == 1
    assert list.include?('test_db')
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

  def test_db_create_with_files_including_compressed
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
    Db.create(@conn, 'test_db')
    response = Db.drop(@conn, 'test_db')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert message.end_with?('was successfully dropped.')
  end

  def test_db_clear
    Db.create(
      @conn, 'test_db', {},
      [fixture_file('beatles.ttl'), '']
    )
    assert Db.size(@conn, 'test_db').body == '28'
    Transaction.with_transaction(@conn, 'test_db') do |transaction_id|
      Db.clear(@conn, 'test_db', transaction_id)
    end
    assert Db.size(@conn, 'test_db').body == '0'
  end

  def test_db_size
    Db.create(
      @conn, 'test_db', {},
      [fixture_file('beatles.ttl'), '']
    )
    response = Db.size(@conn, 'test_db')
    assert response.code == '200'
    assert response.body == '28'
  end

  def test_db_online
    Db.create(@conn, 'test_db', 'database.online' => false)
    response = Db.online(@conn, 'test_db')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert message.end_with?('was successfully brought online')
  end

  def test_db_offline
    Db.create(@conn, 'test_db')
    response = Db.offline(@conn, 'test_db')
    response_json = JSON.parse(response.body)
    message = response_json['message']
    assert response.code == '200'
    assert response.content_type == 'application/json'
    assert message.end_with?('was successfully set offline.')
  end

  def test_db_set_options
    Db.create(@conn, 'test_db', 'database.online' => false)

    options = {
      'search.enabled' => true,
      'reasoning.type' => 'DL'
    }
    response = Db.set_options(@conn, 'test_db', options)
    assert response.code == '200'
    assert response.body =~ /option.*were successfully set/
  end

  def test_db_get_options
    Db.create(@conn, 'test_db')
    options = {
      'search.enabled' => nil, 'reasoning.type' => nil
    }
    response = Db.get_options(@conn, 'test_db', options)
    response_json = JSON.parse(response.body)
    assert response.code == '200'
    assert response_json.key? 'search.enabled'
    assert response_json.key? 'reasoning.type'
    refute response_json.key? 'database.online'
  end
end
