require 'helper'

class TestRequest < Test::Unit::TestCase
    def setup
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:123456789:My-Topic" #arn:aws:sns:us-east-1:123456789:My-Topic
      @host= "#{@product}.#{@region}.amazonaws.com"
      @workers= Rubizon::Workers.new(
        Rubizon::SecurityCredentials.new('00000000000000000000','1234567890')
      )
      @eCommerceServiceProduct= Rubizon::AbstractSig2Product.new(
        :scheme=>'http',
        :host=>'webservices.amazon.com',
        :path=>'/onca/xml',
        '_omit' => ['SignatureMethod','SignatureVersion']
      )
      @eCommerceServiceRequestElements= {
        'Service'=>'AWSECommerceService',
        'Operation'=>'ItemLookup',
        'ItemId'=>'0679722769',
        'ResponseGroup'=>'ItemAttributes,Offers,Images,Reviews',
        'Version'=>'2009-01-06',
        'Timestamp'=>'2009-01-01T12:00:00Z'
      }
      @expectedSignature= 'Nace%2BU3Az4OhN7tISqgs1vdLBHBEijWcBeCqL5xN9xg%3D'
    end
    def test_reports_the_products_host
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@workers)
      assert_equal req.host, @host
    end
    def test_reports_the_products_scheme
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@workers)
      assert_equal 'https', req.scheme
    end
    def test_reports_the_products_path
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@workers)
      assert_equal '/', req.path
    end
    def test_reports_the_products_endpoint
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@workers)
      assert_equal 'https://sns.us-east-1.amazonaws.com/',req.endpoint
    end
    def test_creates_a_URL_that_contains_the_expected_host_name_for_the_sample_request
      req= @eCommerceServiceProduct.create_request(@workers)
      req.add_query_elements @eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      assert_equal @eCommerceServiceProduct.host,uri.host
    end
    def test_creates_a_URL_that_contains_the_expected_path_for_the_sample_request
      req= @eCommerceServiceProduct.create_request(@workers)
      req.add_query_elements @eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      assert_equal @eCommerceServiceProduct.path,uri.path
    end
    def test_creates_a_URL_that_contains_the_expected_scheme_for_the_sample_request
      req= @eCommerceServiceProduct.create_request(@workers)
      req.add_query_elements @eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      assert_equal @eCommerceServiceProduct.scheme,uri.scheme
    end
    def test_creates_a_URL_that_contains_the_expected_query_string_for_the_sample_request
      req= @eCommerceServiceProduct.create_request(@workers)
      req.add_query_elements @eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      query= CGI::parse(uri.query)
      @eCommerceServiceRequestElements.each do |k,v|
        assert_equal query.delete(k).first, v
      end
      assert_equal query.delete('AWSAccessKeyId').first, @workers.credentials.accessID
      assert_equal CGI::escape(query.delete('Signature').first), @expectedSignature
      assert query.empty?   #there's nothing left!  All elements are accounted for
    end
end
