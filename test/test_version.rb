require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Version" do
    it "reports its version" do
      assert_equal "#{Rubizon::Version::MAJOR}.#{Rubizon::Version::MINOR}.#{Rubizon::Version::PATCH}", Rubizon::Version::STRING
    end
end
