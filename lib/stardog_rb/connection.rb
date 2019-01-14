require 'net/http'

module Stardog
  # Hold connection information
  class Connection
    MULTIPART_BOUNDARY = '----MultipartBoundary'.freeze
    RDF_EXTENSION_CONTENT_TYPES = {
      'ttl' => 'text/turtle',
      'rdf' => 'application/rdf+xml',
      'rdfs' => 'application/rdf+xml',
      'owl' => 'application/rdf+xml',
      'xml' => 'application/rdf+xml',
      'nt' => 'application/n-triples',
      'n3' => 'text/n3',
      'nq' => 'application/n-quads',
      'nquads' => 'application/n-quads',
      'trig' => 'application/trig',
      'trix' => 'application/trix',
      'json' => 'application/ld+json',
      'jsonld' => 'application/ld+json'
    }.freeze

    COMPRESSED_ENCODINGS = {
      'gz' => 'gzip', 'zip' => 'zip', 'bz2' => 'bzip2'
    }.freeze

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

    def multipart_form_data(form_data)
      "--#{MULTIPART_BOUNDARY}\r\n" \
      "Content-Disposition: form-data; name=\"root\"\r\n\r\n#{form_data}\r\n"
    end

    def guess_content_type(file_name)
      extension = File.extname(file_name)
      encoding = COMPRESSED_ENCODINGS.fetch(extension, '')
      extension = file_name.split('.')[-2] unless encoding.empty?
      content_type = RDF_EXTENSION_CONTENT_TYPES[extension[1..-1]]
      [content_type, encoding]
    end

    def multipart_file(file)
      file_name = File.basename(file)
      content_type, encoding = guess_content_type(file_name)
      encoding = encoding.empty? ? '' : "Content-Encoding: #{encoding}"

      "--#{MULTIPART_BOUNDARY}\r\n" \
      "Content-Disposition: form-data; name=\"#{file_name}\"; " \
      "filename=\"#{file_name}\"\r\n" \
      "Content-Type: #{content_type}\r\n\r\n" \
      "#{encoding}" \
      "#{File.read(file)}\r\n"
    end

    def multipart_request(request, form_data, files)
      request.set_content_type(
        'multipart/form-data', 'boundary' => MULTIPART_BOUNDARY
      )
      body = []
      body.push(multipart_form_data(form_data)) unless form_data.empty?
      body.concat(files.collect { |f| multipart_file(f) })
      body.push("--#{MULTIPART_BOUNDARY}--\r\n")
      request.body = body.join
      request
    end

    def post_request_multipart(form_data, params, files, *resource)
      uri = self.uri(*resource)
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(@username, @password)
      multipart_request(request, form_data, files)
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
