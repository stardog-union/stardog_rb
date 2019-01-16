module Stardog
  # Control the Stardog server
  module Server
    class << self
      def status(conn)
        request = conn.get_request('admin', 'status')
        Stardog::Connection.extract_json(
          conn.response(request, 'application/json').body
        )
      end

      def shutdown(conn)
        request = conn.post_request({}, {}, 'admin', 'shutdown')
        conn.response(request, 'application/json')
        :ok
      end
    end
  end
end
