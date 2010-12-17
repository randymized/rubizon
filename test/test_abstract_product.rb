require 'helper'

class TestAbstractProduct < Test::Unit::TestCase
  context "An AbstractProduct instance" do
    setup do
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:698519295917:My-Topic" #arn:aws:sns:us-east-1:698519295917:My-Topic
    end
    should "calculate the URI if only an ARN is specified" do
      # If the ARN is: arn:aws:sns:us-east-1:698519295917:My-Topic
      # the URI would be: http://sns.us-east-1.amazonaws.com/
      # The URI may be specified specifically if it cannot be deduced from the ARN in this way
      prod= Rubizon::AbstractProduct.new(:arn=>@arn)
      assert_equal "http://#{@product}.#{@region}.amazonaws.com/", prod.base_uri
    end
    should "calculate the URI if only an ARN and a scheme is specified" do
      prod= Rubizon::AbstractProduct.new(:arn=>@arn,:scheme=>:https)
      assert_equal "https://#{@product}.#{@region}.amazonaws.com/", prod.base_uri
    end
    should "calculate the URI if only host is specified" do
      prod= Rubizon::AbstractProduct.new(:host=>'example.com')
      assert_equal "http://example.com/", prod.base_uri
    end
    should "calculate the URI if only host and scheme is specified" do
      prod= Rubizon::AbstractProduct.new(:host=>'example.com',:scheme=>'https')
      assert_equal "https://example.com/", prod.base_uri
    end
    should "prefer a specified URI over one built from ARN, host or scheme" do
      uri= 'http://foo.com/xxx'
      prod= Rubizon::AbstractProduct.new(:uri=>uri,:host=>'example.com',:scheme=>'https',:arn=>@arn)
      assert_equal uri, prod.base_uri
    end
  end
end

