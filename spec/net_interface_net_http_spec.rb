require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "The network interface based on Net::HTTP" do
  def a_test(method,scheme)
    @sdb= Rubizon::SimpleDBService.new(TestWorker,:method=>method,:scheme=>scheme)
    request= @sdb.list_domains
    request.method= method
    request.method.should == method.to_s
    request.scheme.should == scheme.to_s
    r= Rubizon::NetworkInterface::NetHTTP.new.call(request)
    r.status.should == 200
    r.body.should be_a String
  end
  it "sends a HTTP GET request" do
    a_test(:GET,:http);
  end
  it "sends a HTTPS GET request" do
    a_test(:GET,:https);
  end
  it "sends a HTTP POST request" do
    a_test(:POST,:http);
  end
  it "sends a HTTPS POST request" do
    a_test(:POST,:https);
  end
end
