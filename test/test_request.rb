require 'helper'

class TestRequest < Test::Unit::TestCase
  @@credentials= Rubizon::SecurityCredentials.new('00000000000000000000','1234567890')
  @@eCommerceServiceProduct= Rubizon::AbstractSig2Product.new(
    :scheme=>'http',
    :host=>'webservices.amazon.com',
    :path=>'/onca/xml',
    '_omit' => ['SignatureMethod','SignatureVersion']
  )
  @@eCommerceServiceRequestElements= {
    'Service'=>'AWSECommerceService',
    'Operation'=>'ItemLookup',
    'ItemId'=>'0679722769',
    'ResponseGroup'=>'ItemAttributes,Offers,Images,Reviews',
    'Version'=>'2009-01-06',
    'Timestamp'=>'2009-01-01T12:00:00Z'
  }
  @@expectedSignature= 'Nace%2BU3Az4OhN7tISqgs1vdLBHBEijWcBeCqL5xN9xg%3D'
  context "A Request instance" do
    setup do
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:123456789:My-Topic" #arn:aws:sns:us-east-1:123456789:My-Topic
      @host= "#{@product}.#{@region}.amazonaws.com"
    end
    should "report the product's host" do
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@@credentials)
      assert_equal @host, req.host
    end
    should "report the product's scheme" do
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@@credentials)
      assert_equal 'https', req.scheme
    end
    should "report the product's path" do
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@@credentials)
      assert_equal '/', req.path
    end
    should "report the product's endpoint" do
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@@credentials)
      assert_equal 'https://sns.us-east-1.amazonaws.com/', req.endpoint
    end
    should "Create a URL that contains the expected host name for the sample request" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action_query_elements @@eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.host, uri.host
    end
    should "Create a URL that contains the expected path for the sample request" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action_query_elements @@eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.path, uri.path
    end
    should "Create a URL that contains the expected scheme for the sample request" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action_query_elements @@eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.scheme, uri.scheme
    end
    should "Create a URL that contains the expected query string for the sample request" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action_query_elements @@eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      query= CGI::parse(uri.query)
      @@eCommerceServiceRequestElements.each do |k,v|
        assert_equal query.delete(k).first, v
      end
      assert_equal query.delete('AWSAccessKeyId').first, @@credentials.accessID
      assert_equal CGI::escape(query.delete('Signature').first), @@expectedSignature
      assert query.empty?   #there's nothing left!  All elements are accounted for
    end
  end
end
