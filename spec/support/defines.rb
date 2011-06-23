#access and secret ids are from the example REST requests at
#http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html
AWSAccessKeyId='00000000000000000000'
SecretAccessKeyId= '1234567890'

# The following file is not committed into the project and must be provided by you.
# A sample, for you to modify and save as private/aws.rb can be found at 
# sample/private/aws.rb
require File.dirname(__FILE__) + '/../../private/aws'

require 'rubizon/network_interfaces/net_http'

TestWorker= Rubizon::Workers.new(TestCredentials,Rubizon::NetworkInterface::NetHTTP.new)
