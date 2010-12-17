require 'helper'

class TestAbstractSig2Product < Test::Unit::TestCase
  context "A Request instance" do
    should "calculate the signature expected in the example at http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html" do
      prod= Rubizon::AbstractSig2Product.new(
        :scheme=>'http',
        :host=>'webservices.amazon.com',
        :path=>'/onca/xml',
        '_omit' => ['SignatureMethod','SignatureVersion']
      )
      req= prod.create_request(Rubizon::Identifier.new('00000000000000000000','1234567890'))
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

