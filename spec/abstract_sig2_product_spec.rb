require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AbstractSig2Product" do
    before do
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:123456789:My-Topic" #arn:aws:sns:us-east-1:123456789:My-Topic
    end
    it "calculates the hostname if only an ARN is specified" do
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the host would be: sns.us-east-1.amazonaws.com
      # The host may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn)
      prod.host.should == "#{@product}.#{@region}.amazonaws.com"
    end
    it "returns any specific host name, even if a different one might be calculated from a specified ARN" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn, :host=>'foo.com')
      prod.host.should == 'foo.com'
    end
    it "determines the host if given a URL" do
      prod= Rubizon::AbstractSig2Product.new(:url=>'http://foo.com/')
      prod.host.should == 'foo.com'
    end
    it "determines the scheme if given a URL" do
      prod= Rubizon::AbstractSig2Product.new(:url=>'ftp://foo.com/')
      prod.scheme.should == 'ftp'
    end
    it "determines the path if given a URL" do
      prod= Rubizon::AbstractSig2Product.new(:url=>'http://foo.com/bar')
      prod.path.should == '/bar'
    end
    it "calculates the URL if only an ARN is specified" do
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the URL would be: https://sns.us-east-1.amazonaws.com/
      # The host may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn)
      prod.endpoint.should == "https://#{@product}.#{@region}.amazonaws.com/"
    end
    it "calculates the URL if only an ARN and a scheme is specified" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn,:scheme=>:http)
      prod.endpoint.should == "http://#{@product}.#{@region}.amazonaws.com/"
    end
    it "calculates the URL if only host is specified" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'example.com')
      prod.endpoint.should == "https://example.com/"
    end
    it "prefers a specified host over one built from ARN" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'foo.com',:scheme=>'http',:arn=>@arn)
      prod.endpoint.should == 'http://foo.com/'
    end
    it "returns any specified path" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'x.com',:path=>'abc/xyz')
      prod.path.should == 'abc/xyz'
    end
    it "appends any specified path to a URL generated from an ARN" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn, :path=>'/abc/xyz')
      prod.endpoint.should == "https://#{@product}.#{@region}.amazonaws.com/abc/xyz"
    end
    it "returns query elements not related to specifying the endpoint in the query_elements hash" do
      prod= Rubizon::AbstractSig2Product.new(
        'arn'=>@arn, 
        'scheme'=>'http',
        'host'=>'foo.com', 
        'path'=>'/abc/xyz',
        'foo'=>'bar'
      )
      prod.query_elements.size.should == 4
      prod.query_elements['foo'].should == 'bar'
      prod.query_elements['SignatureMethod'].should == 'HmacSHA256'
      prod.query_elements['SignatureVersion'].should == 2
    end
end

