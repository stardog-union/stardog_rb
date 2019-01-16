require 'stardog_rb/version'
require 'stardog_rb/multipart'
require 'stardog_rb/connection'
require 'stardog_rb/server'
require 'stardog_rb/db/db'
require 'stardog_rb/db/transaction'
require 'stardog_rb/query/query'

# The main module
module Stardog
  class Error < StandardError; end
end
