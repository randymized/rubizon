require 'helper'

class TestAction < Test::Unit::TestCase
  @@credentials= Rubizon::SecurityCredentials.new('00000000000000000000','1234567890')
  @@eCommerceServiceProduct= Rubizon::AbstractSig2Product.new(
    :scheme=>'http',
    :host=>'webservices.amazon.com',
    :path=>'/onca/xml',
    '_omit' => ['SignatureMethod','SignatureVersion'],
    'Service'=>'AWSECommerceService'
  )
  @@itemLookupAction= Rubizon::Action.new(
    'Operation'=>'ItemLookup'
  )
  @@eCommerceServiceRequestSubject= {
    'ItemId'=>'0679722769',
    'ResponseGroup'=>'ItemAttributes,Offers,Images,Reviews',
    'Version'=>'2009-01-06',
    'Timestamp'=>'2009-01-01T12:00:00Z'
  }
  @@expectedSignature= 'Nace%2BU3Az4OhN7tISqgs1vdLBHBEijWcBeCqL5xN9xg%3D'
  context "An Action instance" do
    should "report the action's query elements" do
      q= @@itemLookupAction.query_elements
      assert_equal 'ItemLookup', q.delete('Operation')
      assert q.empty?   #there's nothing left!  All elements are accounted for
    end
    should "report the action's append_this_to_path component" do
      a= Rubizon::Action.new('action'=>'something')
      a.append_this_to_path= 'abc/xyz'
      assert_equal 'abc/xyz', a.append_this_to_path
    end
    should "calculate the signature (version 2) expected in the example at http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action @@itemLookupAction, @@eCommerceServiceRequestSubject
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
      assert_equal @@expectedSignature, CGI::escape(CGI::parse(q)['Signature'].first)
    end
    should "Create a URL that contains the expected host name for the sample request" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action @@itemLookupAction, @@eCommerceServiceRequestSubject
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.host, uri.host
    end
    should "Create a URL that contains the expected path for the sample request" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action @@itemLookupAction, @@eCommerceServiceRequestSubject
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.path, uri.path
    end
    should "Create a URL that contains the expected scheme for the sample request" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action @@itemLookupAction, @@eCommerceServiceRequestSubject
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.scheme, uri.scheme
    end
    should "Create a URL that contains the expected query string for the sample request" do
      req= @@eCommerceServiceProduct.create_request(@@credentials)
      req.add_action @@itemLookupAction, @@eCommerceServiceRequestSubject
      uri = URI.parse(req.url);
      query= CGI::parse(uri.query)
      @@eCommerceServiceRequestSubject.each do |k,v|
        assert_equal query.delete(k).first, v
      end
      @@itemLookupAction.query_elements.each do |k,v|
        assert_equal query.delete(k).first, v
      end
      assert_equal 'AWSECommerceService', CGI::escape(query.delete('Service').first)
      assert_equal @@credentials.accessID, query.delete('AWSAccessKeyId').first
      assert_equal @@expectedSignature, CGI::escape(query.delete('Signature').first)
      assert query.empty?   #there's nothing left!  All elements are accounted for
    end
  end
end
