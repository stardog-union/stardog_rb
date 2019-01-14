require 'test_helper'
require 'stardog_rb'

class TransactionTest < Minitest::Test
  Transaction = Stardog::Db::Transaction

  def setup
    @conn = Stardog::Connection.new
    VCR.insert_cassette name
  end

  def teardown
    VCR.eject_cassette
  end

  def guid?(str)
    # Lifted from https://stackoverflow.com/a/13653180/1011616
    reg = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5]
           [0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/ix
    str =~ reg
  end

  def test_begin_transaction
    response = Transaction.begin(@conn, 'test_db')
    assert response.code == '200'
    assert guid?(response.body)
  end

  def test_rollback_empty_transaction
    transaction_id = Transaction.begin(@conn, 'test_db').body
    rollback_response = Transaction.rollback(
      @conn, 'test_db', transaction_id
    )
    assert rollback_response.code == '200'
    assert rollback_response.body == ''
  end

  def test_commit_empty_transaction
    transaction_id = Transaction.begin(@conn, 'test_db').body
    commit_response = Transaction.rollback(
      @conn, 'test_db', transaction_id
    )
    assert commit_response.code == '200'
    assert commit_response.body == ''
  end
end
