require 'test_helper'

class StardogTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Stardog::VERSION
  end
end
