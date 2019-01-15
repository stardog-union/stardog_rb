$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'stardog_rb'
require 'minitest/autorun'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end

def fixture_file(file_name)
  File.new(File.expand_path("fixtures/#{file_name}", __dir__))
end

def without_vcr
  VCR.configure do |c|
    c.allow_http_connections_when_no_cassette = true
    yield
    c.allow_http_connections_when_no_cassette = false
  end
end
