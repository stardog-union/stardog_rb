module Stardog
  module Db
    # Manage transactions
    module Transaction
      class << self
        def begin(conn, database)
          request = conn.post_request({}, {}, database, 'transaction', 'begin')
          conn.response(request, '*/*')
        end

        def rollback(conn, database, transaction_id)
          request = conn.post_request(
            {}, {}, database, 'transaction', 'rollback', transaction_id
          )
          conn.response(request, '*/*')
        end

        def commit(conn, database, transaction_id)
          request = conn.post_request(
            {}, {}, database, 'transaction', 'commit', transaction_id
          )
          conn.response(request, '*/*')
        end

        def with_transaction(conn, database)
          transaction_id = self.begin(conn, database).body
          yield transaction_id
          commit(conn, database, transaction_id)
        end
      end
    end
  end
end
