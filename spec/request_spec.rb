require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Request" do
    before do
      @region= 'us-east-1'
      @product= 'sns'
      @arn= "arn:aws:#{@product}:#{@region}:123456789:My-Topic" #arn:aws:sns:us-east-1:123456789:My-Topic
      @host= "#{@product}.#{@region}.amazonaws.com"
      @credentials= Rubizon::SecurityCredentials.new('00000000000000000000','1234567890')
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
    it "reports the product's host" do
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@credentials)
      @host.should == req.host
    end
    it "reports the product's scheme" do
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@credentials)
      req.scheme.should == 'https'
    end
    it "reports the product's path" do
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@credentials)
      req.path.should == '/'
    end
    it "reports the product's endpoint" do
      prod= Rubizon::AbstractSig2Product.new(
        :arn=>@arn
      )
      req= prod.create_request(@credentials)
      req.endpoint.should == 'https://sns.us-east-1.amazonaws.com/'
    end
    it "Creates a URL that contains the expected host name for the sample request" do
      req= @eCommerceServiceProduct.create_request(@credentials)
      req.add_query_elements @eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      uri.host.should == @eCommerceServiceProduct.host
    end
    it "Creates a URL that contains the expected path for the sample request" do
      req= @eCommerceServiceProduct.create_request(@credentials)
      req.add_query_elements @eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      uri.path.should == @eCommerceServiceProduct.path
    end
    it "Creates a URL that contains the expected scheme for the sample request" do
      req= @eCommerceServiceProduct.create_request(@credentials)
      req.add_query_elements @eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      uri.scheme.should == @eCommerceServiceProduct.scheme
    end
    it "Creates a URL that contains the expected query string for the sample request" do
      req= @eCommerceServiceProduct.create_request(@credentials)
      req.add_query_elements @eCommerceServiceRequestElements
      uri = URI.parse(req.url);
      query= CGI::parse(uri.query)
      @eCommerceServiceRequestElements.each do |k,v|
        v.should == query.delete(k).first
      end
      @credentials.accessID.should == query.delete('AWSAccessKeyId').first
      @expectedSignature.should == CGI::escape(query.delete('Signature').first)
      query.should be_empty   #there's nothing left!  All elements are accounted for
    end
end
