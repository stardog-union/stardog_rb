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

        def online(conn, database)
          path = ['admin', 'databases', database, 'online']
          request = conn.put_request({}, {}, *path)
          conn.response(request)
        end

        def offline(conn, database)
          path = ['admin', 'databases', database, 'offline']
          request = conn.put_request({}, {}, *path)
          conn.response(request)
        end

        def set_options(conn, database, options)
          path = ['admin', 'databases', database, 'options']
          request = conn.post_request(options.to_json, {}, *path)
          request.content_type = 'application/json'
          conn.response(request, 'application/json')
        end

        def get_options(conn, database, options)
          path = ['admin', 'databases', database, 'options']
          request = conn.put_request(options.to_json, {}, *path)
          request.content_type = 'application/json'
          conn.response(request, 'application/json')
        end
      end
    end
  end
end
