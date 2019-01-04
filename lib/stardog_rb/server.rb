require 'net/http'
require 'stardog_rb/connection'

module StardogRb
  # Control the Stardog server
  class Server
    class << self
      def status(conn)
        request = conn.get_request('admin', 'status')
        conn.response(request, 'application/json')
      end

      def shutdown(conn)
        request = conn.post_request({}, 'admin', 'shutdown')
        conn.response(request, 'application/json')
      end
    end
  end
end
