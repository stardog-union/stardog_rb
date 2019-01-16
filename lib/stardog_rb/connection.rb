require 'net/http'

module Stardog
  # Hold connection information
  class Connection
    class << self
      def format_error(response)
        "#{response.code}: #{response.body}"
      end

      def success?(response)
        response.code =~ /^2\d{2}$/
      end

      def raise_on_error(response)
        raise Stardog::Error, format_error(response) unless success?(response)
      end

      def extract_json(body, key = nil)
        result = JSON.parse(body)

        if key
          result = result[key]
          error_msg = "Expected key #{key} not found in response"
          raise Stardog::Error, error_msg unless result
        end

        result
      end
    end

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
        response = http.request(request)
        self.class.raise_on_error(response)
        response
      end
    end
  end
end
