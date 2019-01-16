require 'test_helper'
require 'stardog_rb'

class TransactionTest < Minitest::Test
  Transaction = Stardog::Db::Transaction

  def setup
    @conn = Stardog::Connection.new
    without_vcr do
      drop_test_db(@conn)
      Stardog::Db.create(@conn, 'test_db')
    end
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
    assert guid?(response)
  end

  def test_rollback_empty_transaction
    transaction_id = Transaction.begin(@conn, 'test_db')
    rollback_response = Transaction.rollback(
      @conn, 'test_db', transaction_id
    )
    assert rollback_response == :ok
  end

  def test_commit_empty_transaction
    transaction_id = Transaction.begin(@conn, 'test_db')
    response = Transaction.commit(
      @conn, 'test_db', transaction_id
    )
    assert response['added'].zero?
    assert response['removed'].zero?
  end
end
