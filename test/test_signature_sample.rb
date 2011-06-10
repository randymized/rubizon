require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# This is a special test based upon a signature generation sample at
# http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?rest-signature.html
# That is the only sample I know of where an actual signature, based upon
# simulated security credentials and request parameters is documented.

# This also serves as a test of the integration of security credentials,
# Actions, Products and Requests in order to generate a properly formed URL.

describe "Signature generation sample" do
  @@credentials= Rubizon::SecurityCredentials.new('00000000000000000000','1234567890')
  @@eCommerceServiceProduct= Rubizon::ProductAdvertisingProduct.new(@@credentials)
  @@eCommerceServiceRequestSubject= {
    'ItemId'=>'0679722769',
    'ResponseGroup'=>'ItemAttributes,Offers,Images,Reviews',
    'Version'=>'2009-01-06',
    'Timestamp'=>'2009-01-01T12:00:00Z'
  }
  @@expectedSignature= 'Nace%2BU3Az4OhN7tISqgs1vdLBHBEijWcBeCqL5xN9xg%3D'
    it "calculates the signature (version 2) expected in the example" do
      req= @@eCommerceServiceProduct.item_lookup_request(@@eCommerceServiceRequestSubject)
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
    it "Creates a URL that contains the expected host name for the sample request" do
      req= @@eCommerceServiceProduct.item_lookup_request(@@eCommerceServiceRequestSubject)
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.host, uri.host
    end
    it "Creates a URL that contains the expected path for the sample request" do
      req= @@eCommerceServiceProduct.item_lookup_request(@@eCommerceServiceRequestSubject)
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.path, uri.path
    end
    it "Creates a URL that contains the expected scheme for the sample request" do
      req= @@eCommerceServiceProduct.item_lookup_request(@@eCommerceServiceRequestSubject)
      uri = URI.parse(req.url);
      assert_equal @@eCommerceServiceProduct.scheme, uri.scheme
    end
    it "Creates a URL that contains the expected query string for the sample request" do
      req= @@eCommerceServiceProduct.item_lookup_request(@@eCommerceServiceRequestSubject)
      uri = URI.parse(req.url);
      query= CGI::parse(uri.query)
      @@eCommerceServiceRequestSubject.each do |k,v|
        assert_equal query.delete(k).first, v
      end
      assert_equal 'ItemLookup', CGI::escape(query.delete('Operation').first)
      assert_equal 'AWSECommerceService', CGI::escape(query.delete('Service').first)
      assert_equal @@credentials.accessID, query.delete('AWSAccessKeyId').first
      assert_equal @@expectedSignature, CGI::escape(query.delete('Signature').first)
      assert query.empty?   #there's nothing left!  All elements are accounted for
    end
end
