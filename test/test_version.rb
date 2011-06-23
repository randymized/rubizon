require 'helper'

class TestVersion < Test::Unit::TestCase
  def test_reports_version
    assert_equal("#{Rubizon::Version::MAJOR}.#{Rubizon::Version::MINOR}.#{Rubizon::Version::PATCH}", Rubizon::Version::STRING)
  end
end
