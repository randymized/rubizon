require 'helper'

class TestAbstractSig2Product < Test::Unit::TestCase
    def setup
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:123456789:My-Topic" #arn:aws:sns:us-east-1:123456789:My-Topic
    end
    def test_calculates_the_hostname_if_only_an_ARN_is_specified
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the host would be: sns.us-east-1.amazonaws.com
      # The host may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn)
      assert_equal "#{@product}.#{@region}.amazonaws.com", prod.host
    end
    def test_returns_any_specific_host_name_even_if_a_different_one_might_be_calculated_from_a_specified_ARN
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn, :host=>'foo.com')
      assert_equal 'foo.com', prod.host
    end
    def test_determines_the_host_if_given_a_URL
      prod= Rubizon::AbstractSig2Product.new(:url=>'http://foo.com/')
      assert_equal 'foo.com', prod.host
    end
    def test_determines_the_scheme_if_given_a_URL
      prod= Rubizon::AbstractSig2Product.new(:url=>'ftp://foo.com/')
      assert_equal 'ftp', prod.scheme
    end
    def test_determines_the_path_if_given_a_URL
      prod= Rubizon::AbstractSig2Product.new(:url=>'http://foo.com/bar')
      assert_equal '/bar', prod.path
    end
    def test_calculates_the_URL_if_only_an_ARN_is_specified
      # If the ARN is: arn:aws:sns:us-east-1:123456789:My-Topic
      # the URL would be: https://sns.us-east-1.amazonaws.com/
      # The host may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn)
      assert_equal "https://#{@product}.#{@region}.amazonaws.com/", prod.endpoint
    end
    def test_calculates_the_URL_if_only_an_ARN_and_a_scheme_is_specified
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn,:scheme=>:http)
      assert_equal "http://#{@product}.#{@region}.amazonaws.com/", prod.endpoint
    end
    def test_calculates_the_URL_if_only_host_is_specified
      prod= Rubizon::AbstractSig2Product.new(:host=>'example.com')
      assert_equal "https://example.com/", prod.endpoint
    end
    def test_prefers_a_specified_host_over_one_built_from_ARN
      prod= Rubizon::AbstractSig2Product.new(:host=>'foo.com',:scheme=>'http',:arn=>@arn)
      assert_equal 'http://foo.com/', prod.endpoint
    end
    def test_returns_any_specified_path
      prod= Rubizon::AbstractSig2Product.new(:host=>'x.com',:path=>'abc/xyz')
      assert_equal 'abc/xyz', prod.path
    end
    def test_appends_any_specified_path_to_a_URL_generated_from_an_ARN
      prod= Rubizon::AbstractSig2Product.new(:arn=>@arn, :path=>'/abc/xyz')
      assert_equal "https://#{@product}.#{@region}.amazonaws.com/abc/xyz", prod.endpoint
    end
    def test_returns_query_elements_not_related_to_specifying_the_endpoint_in_the_query_elements_hash
      prod= Rubizon::AbstractSig2Product.new(
        'arn'=>@arn, 
        'scheme'=>'http',
        'host'=>'foo.com', 
        'path'=>'/abc/xyz',
        'foo'=>'bar'
      )
      assert_equal 4, prod.query_elements.size
      assert_equal 'bar',prod.query_elements['foo']
      assert_equal 'HmacSHA256',prod.query_elements['SignatureMethod']
      assert_equal 2,prod.query_elements['SignatureVersion']
    end
end

