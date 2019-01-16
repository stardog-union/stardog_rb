require 'net/http'

module Stardog
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

    def post_request(form_data, params, *resource)
      uri = self.uri(*resource)
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(@username, @password)
      request.body = form_data unless form_data.empty?
      request
    end

    def post_request_multipart(form_data, params, files, *resource)
      uri = self.uri(*resource)
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(@username, @password)
      Stardog::Multipart.multipart_request(request, form_data, files)
    end

    def put_request(form_data, params, *resource)
      uri = self.uri(*resource)
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Put.new(uri)
      request.basic_auth(@username, @password)
      request.body = form_data unless form_data.empty?
      request
    end

    def delete_request(*resource)
      uri = self.uri(*resource)
      request = Net::HTTP::Delete.new(uri)
      request.basic_auth(@username, @password)
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
