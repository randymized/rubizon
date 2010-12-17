require 'helper'

class TestAbstractSig2Product < Test::Unit::TestCase
  context "An AbstractSig2Product instance" do
    setup do
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:123456789:My-Topic" #arn:aws:sns:us-east-1:123456789:My-Topic
    end
    should "calculate the hostname if only an ARN is specified" do
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the host would be: sns.us-east-1.amazonaws.com
      # The host may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn)
      assert_equal "#{@product}.#{@region}.amazonaws.com", prod.host
    end
    should "return any specific host name, even if a different one might be calculated from a specified ARN" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn, :host=>'foo.com')
      assert_equal 'foo.com', prod.host
    end
    should "calculate the URL if only an ARN is specified" do
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the URL would be: https://sns.us-east-1.amazonaws.com/
      # The host may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn)
      assert_equal "https://#{@product}.#{@region}.amazonaws.com/", prod.endpoint
    end
    should "calculate the URL if only an ARN and a scheme is specified" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn,:scheme=>:http)
      assert_equal "http://#{@product}.#{@region}.amazonaws.com/", prod.endpoint
    end
    should "calculate the URL if only host is specified" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'example.com')
      assert_equal "https://example.com/", prod.endpoint
    end
    should "prefer a specified host over one built from ARN" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'foo.com',:scheme=>'http',:arn=>@arn)
      assert_equal 'http://foo.com/', prod.endpoint
    end
    should "return any specified path" do
      prod= Rubizon::AbstractSig2Product.new(:host=>'x.com',:path=>'abc/xyz')
      assert_equal 'abc/xyz', prod.path
    end
    should "append any specified path to a URL generated from an ARN" do
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn, :path=>'/abc/xyz')
      assert_equal "https://#{@product}.#{@region}.amazonaws.com/abc/xyz", prod.endpoint
    end
    should "return query elements not related to specifying the endpoint in the query_elements hash" do
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

    should "calculate the signature expected in the example at http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html" do
      prod= Rubizon::AbstractSig2Product.new(
        :scheme=>'http',
        :host=>'webservices.amazon.com',
        :path=>'/onca/xml',
        '_omit' => ['SignatureMethod','SignatureVersion']
      )
      req= prod.create_request
      req.add_access_credentials(Rubizon::Identifier.new('00000000000000000000','1234567890'))
      req.add_action_query_elements(
        'Service'=>'AWSECommerceService',
        'Operation'=>'ItemLookup',
        'ItemId'=>'0679722769',
        'ResponseGroup'=>'ItemAttributes,Offers,Images,Reviews',
        'Version'=>'2009-01-06',
        'Timestamp'=>'2009-01-01T12:00:00Z'
      )
      q= req.query_string
      assert_equal <<____.rstrip, req.canonical_querystring
AWSAccessKeyId=00000000000000000000&ItemId=0679722769&Operation=ItemLookup&ResponseGroup=ItemAttributes%2COffers%2CImages%2CReviews&Service=AWSECommerceService&Timestamp=2009-01-01T12%3A00%3A00Z&Version=2009-01-06
____
      assert_equal <<____.rstrip, req.string_to_sign
GET
webservices.amazon.com
/onca/xml
AWSAccessKeyId=00000000000000000000&ItemId=0679722769&Operation=ItemLookup&ResponseGroup=ItemAttributes%2COffers%2CImages%2CReviews&Service=AWSECommerceService&Timestamp=2009-01-01T12%3A00%3A00Z&Version=2009-01-06
____
      assert_equal 'Nace%2BU3Az4OhN7tISqgs1vdLBHBEijWcBeCqL5xN9xg%3D', CGI::escape(CGI::parse(q)['Signature'].first)
    end
  end
end

