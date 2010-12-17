require 'helper'

class TestAbstractProduct < Test::Unit::TestCase
  context "An AbstractProduct instance" do
    setup do
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:698519295917:My-Topic" #arn:aws:sns:us-east-1:698519295917:My-Topic
    end
    should "calculate the URL if only an ARN is specified" do
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the URL would be: http://sns.us-east-1.amazonaws.com/
      # The URL may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractProduct.new(:arn=>@arn)
      assert_equal "http://#{@product}.#{@region}.amazonaws.com/", prod.base_url
    end
    should "calculate the URL if only an ARN and a scheme is specified" do
      prod= Rubizon::AbstractProduct.new(:arn=>@arn,:scheme=>:https)
      assert_equal "https://#{@product}.#{@region}.amazonaws.com/", prod.base_url
    end
    should "calculate the URL if only host is specified" do
      prod= Rubizon::AbstractProduct.new(:host=>'example.com')
      assert_equal "http://example.com/", prod.base_url
    end
    should "calculate the URL if only host and scheme is specified" do
      prod= Rubizon::AbstractProduct.new(:host=>'example.com',:scheme=>'https')
      assert_equal "https://example.com/", prod.base_url
    end
    should "prefer a specified URL over one built from ARN, host or scheme" do
      url= 'http://foo.com/xxx'
      prod= Rubizon::AbstractProduct.new(:url=>url,:host=>'example.com',:scheme=>'https',:arn=>@arn)
      assert_equal url, prod.base_url
    end
    should "calculate the signature expected in the example at http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html" do
      prod= Rubizon::AbstractProduct.new(:url=>'http://webservices.amazon.com/onca/xml')
      h= 
      q= prod.query_string(
        Rubizon::Identifier.new('00000000000000000000','1234567890'),
        'Service'=>'AWSECommerceService',
        'Operation'=>'ItemLookup',
        'ItemId'=>'0679722769',
        'ResponseGroup'=>'ItemAttributes,Offers,Images,Reviews',
        'Version'=>'2009-01-06',
        'Timestamp'=>'2009-01-01T12:00:00Z',
        '_omit' => ['SignatureMethod','SignatureVersion']
      )
      assert_equal <<____.rstrip, prod.canonical_querystring
AWSAccessKeyId=00000000000000000000&ItemId=0679722769&Operation=ItemLookup&ResponseGroup=ItemAttributes%2COffers%2CImages%2CReviews&Service=AWSECommerceService&Timestamp=2009-01-01T12%3A00%3A00Z&Version=2009-01-06
____
      assert_equal <<____.rstrip, prod.string_to_sign
GET
webservices.amazon.com
/onca/xml
AWSAccessKeyId=00000000000000000000&ItemId=0679722769&Operation=ItemLookup&ResponseGroup=ItemAttributes%2COffers%2CImages%2CReviews&Service=AWSECommerceService&Timestamp=2009-01-01T12%3A00%3A00Z&Version=2009-01-06
____
      assert_equal 'Nace%2BU3Az4OhN7tISqgs1vdLBHBEijWcBeCqL5xN9xg%3D', CGI::escape(CGI::parse(q)['Signature'].first)
    end
  end
end

