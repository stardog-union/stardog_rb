$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'stardog_rb'
require 'minitest/autorun'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end
