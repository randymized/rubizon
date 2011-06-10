require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec'
require 'rubizon'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

#The following file is not committed into the project and must be provided by you.
#It must include a line like the following, except with valid creditials that 
#allow the tests to access all AWS resources needed for the tests.
#TestCredentials= Rubizon::SecurityCredentials.new('<your access key id>','<your secret access key>')
require File.dirname(__FILE__) + '/../private/aws'

RSpec.configure do |config|
  
end
