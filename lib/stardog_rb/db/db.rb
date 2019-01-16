module Stardog
  # Control databases on the Stardog server
  module Db
    Conn = Stardog::Connection

    class << self
      def list(conn)
        request = conn.get_request('admin', 'databases')
        response = conn.response(request, 'application/json')
        Conn.extract_json(response.body, 'databases')
      end

      def form_filenames(files)
        files.collect do |(file, context)|
          { 'filename' => File.basename(file), 'context' => context }
        end
      end

      def create(conn, database, options = {}, *files)
        form_data = {
          'dbname' => database, 'options' => options,
          'files' => form_filenames(files)
        }

        files = files.collect { |(f, _c)| f }
        request = conn.post_request_multipart(
          form_data.to_json, {}, files, 'admin', 'databases'
        )

        response = conn.response(request, 'application/json')
        Conn.extract_json(response.body, 'message')
      end

      def drop(conn, database)
        request = conn.delete_request('admin', 'databases', database)
        response = conn.response(request)
        Conn.extract_json(response.body, 'message')
      end

      def clear(conn, database, transaction_id, params = {})
        request = conn.post_request(
          {}, params, database, transaction_id, 'clear'
        )
        conn.response(request)
        :ok
      end

      def online(conn, database)
        path = ['admin', 'databases', database, 'online']
        request = conn.put_request({}, {}, *path)
        Conn.extract_json(conn.response(request).body, 'message')
      end

      def offline(conn, database)
        path = ['admin', 'databases', database, 'offline']
        request = conn.put_request({}, {}, *path)
        Conn.extract_json(conn.response(request).body, 'message')
      end

      def set_options(conn, database, options)
        path = ['admin', 'databases', database, 'options']
        request = conn.post_request(options.to_json, {}, *path)
        request.content_type = 'application/json'
        response = conn.response(request, 'application/json')
        Conn.extract_json(response.body, 'message')
      end

      def get_options(conn, database, options)
        path = ['admin', 'databases', database, 'options']
        request = conn.put_request(options.to_json, {}, *path)
        request.content_type = 'application/json'
        response = conn.response(request, 'application/json')
        Conn.extract_json(response.body)
      end

      def size(conn, database)
        request = conn.get_request(database, 'size')
        conn.response(request, 'text/plain').body.to_i
      end
    end
  end
end
