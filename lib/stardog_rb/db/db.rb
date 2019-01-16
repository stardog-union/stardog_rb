module Stardog
  # Control databases on the Stardog server
  module Db
    class << self
      def list(conn)
        request = conn.get_request('admin', 'databases')
        response = conn.response(request, 'application/json')
        JSON.parse(response.body)['databases']
      end

      def form_filenames(files)
        files.collect do |(file, context)|
          { 'filename' => File.basename(file), 'context' => context }
        end
      end

      def create(conn, database, options = {}, *files)
        form_data = {
          'dbname' => database,
          'options' => options,
          'files' => form_filenames(files)
        }

        files = files.collect { |(f, _c)| f }
        request = conn.post_request_multipart(
          form_data.to_json, {}, files, 'admin', 'databases'
        )
        conn.response(request, 'application/json')
      end

      def drop(conn, database)
        request = conn.delete_request('admin', 'databases', database)
        conn.response(request)
      end

      def clear(conn, database, transaction_id, params = {})
        request = conn.post_request(
          {}, params, database, transaction_id, 'clear'
        )
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

      def size(conn, database)
        request = conn.get_request(database, 'size')
        conn.response(request, 'text/plain')
      end
    end
  end
end
