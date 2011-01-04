require 'helper'

class TestVersion < Test::Unit::TestCase
  context "Rubizon" do
    should "report its version" do
      assert_equal "#{Rubizon::Version::MAJOR}.#{Rubizon::Version::MINOR}.#{Rubizon::Version::PATCH}", Rubizon::Version::STRING
    end
  end
end
