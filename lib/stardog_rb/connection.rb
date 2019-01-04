require 'net/http'

module StardogRb
  # Hold connection information
  class Connection
    # Use Stardog server default settings if nothing provided
    def initialize(params = {})
      @endpoint = params.fetch(:endpoint, 'http://localhost:5820')
      @endpoint_uri = URI(@endpoint)
      @username = params.fetch(:username, 'admin')
      @password = params.fetch(:password, 'admin')
    end

    def uri(*resource)
      URI("#{@endpoint}/#{resource.join('/')}")
    end

    def get_request(*resource)
      uri = self.uri(*resource)
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(@username, @password)
      request
    end

    def post_request(form_data, *resource)
      uri = self.uri(*resource)
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(@username, @password)
      request.set_form_data(*form_data) unless form_data.empty?
      request
    end

    def response(request, accept = '*/*')
      Net::HTTP.start(@endpoint_uri.host, @endpoint_uri.port) do |http|
        request['Accept'] = accept
        http.request(request)
      end
    end
  end
end
