require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'test/unit'

describe "Version" do
    it "reports its version" do
       Rubizon::Version::STRING.should == "#{Rubizon::Version::MAJOR}.#{Rubizon::Version::MINOR}.#{Rubizon::Version::PATCH}"
    end
end
