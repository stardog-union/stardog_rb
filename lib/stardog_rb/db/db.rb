module StardogRb
  module Db
    # Control databases on the Stardog server
    class Db
      class << self
        def list(conn)
          request = conn.get_request('admin', 'databases')
          conn.response(request, 'application/json')
        end

        def create(conn, database, options = {})
          form_data = {
            'root' => {
              'dbname' => database,
              'options' => options
            }
          }
          request = conn.post_multipart_request(form_data, 'admin', 'databases')
          conn.response(request, 'application/json')
        end

        def drop(conn, database)
          request = conn.delete_request('admin', 'databases', database)
          conn.response(request)
        end
      end
    end
  end
end
