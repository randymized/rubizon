require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubizon'

#access and secret ids are from the example REST requests at
#http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html
AWSAccessKeyId='00000000000000000000'
SecretAccessKeyId= '1234567890'

class Test::Unit::TestCase
end
