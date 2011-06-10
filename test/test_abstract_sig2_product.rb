require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AbstractSig2Product" do
    setup do
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:123456789:My-Topic" #arn:aws:sns:us-east-1:123456789:My-Topic
    end
    it "calculates the hostname if only an ARN is specified" do
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the host would be: sns.us-east-1.amazonaws.com
      # The host may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn)
      assert_equal "#{@product}.#{@region}.amazonaws.com", prod.host
    end
    it "returns any specific host name, even if a different one might be calculated from a specified ARN" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn, :host=>'foo.com')
      assert_equal 'foo.com', prod.host
    end
    it "determines the host if given a URL" do
      prod= Rubizon::AbstractSig2Product.new(:url=>'http://foo.com/')
      assert_equal 'foo.com', prod.host
    end
    it "determines the scheme if given a URL" do
      prod= Rubizon::AbstractSig2Product.new(:url=>'ftp://foo.com/')
      assert_equal 'ftp', prod.scheme
    end
    it "determines the path if given a URL" do
      prod= Rubizon::AbstractSig2Product.new(:url=>'http://foo.com/bar')
      assert_equal '/bar', prod.path
    end
    it "calculates the URL if only an ARN is specified" do
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the URL would be: https://sns.us-east-1.amazonaws.com/
      # The host may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn)
      assert_equal "https://#{@product}.#{@region}.amazonaws.com/", prod.endpoint
    end
    it "calculates the URL if only an ARN and a scheme is specified" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn,:scheme=>:http)
      assert_equal "http://#{@product}.#{@region}.amazonaws.com/", prod.endpoint
    end
    it "calculates the URL if only host is specified" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'example.com')
      assert_equal "https://example.com/", prod.endpoint
    end
    it "prefers a specified host over one built from ARN" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'foo.com',:scheme=>'http',:arn=>@arn)
      assert_equal 'http://foo.com/', prod.endpoint
    end
    it "returns any specified path" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'x.com',:path=>'abc/xyz')
      assert_equal 'abc/xyz', prod.path
    end
    it "appends any specified path to a URL generated from an ARN" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn, :path=>'/abc/xyz')
      assert_equal "https://#{@product}.#{@region}.amazonaws.com/abc/xyz", prod.endpoint
    end
    it "returns query elements not related to specifying the endpoint in the query_elements hash" do
      prod= Rubizon::AbstractSig2Product.new(
        'arn'=>@arn, 
        'scheme'=>'http',
        'host'=>'foo.com', 
        'path'=>'/abc/xyz',
        'foo'=>'bar'
      )
      assert_equal 4, prod.query_elements.size
      assert_equal 'bar', prod.query_elements['foo']
      assert_equal 'HmacSHA256', prod.query_elements['SignatureMethod']
      assert_equal 2, prod.query_elements['SignatureVersion']
    end
end

