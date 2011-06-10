require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SecurityCredentials" do
    before do
      @id= Rubizon::SecurityCredentials.new(AWSAccessKeyId,SecretAccessKeyId)
      @arbitrary_string= 'x'
      @expected_signature= '6KClHg2k6AiXNRwaLa7sC7LIxP4NkUieZheem0eHnBI='
    end
    it "reports the access key ID" do
      @id.accessID.should == AWSAccessKeyId
    end
    it "won't allow accessing the secret access key ID" do
      should_not respond_to :secretID, :secretKeyID, :secretAccessKeyID, :awsSecretAccessKeyID
    end
    it "signs an arbitrary string using the secretID" do
      @id.sign256(@arbitrary_string).should == @expected_signature
    end
    it "produces a different signature if initialized with a different access key" do
      Rubizon::SecurityCredentials.new(AWSAccessKeyId,SecretAccessKeyId+'x').sign256(@arbitrary_string).should_not == @expected_signature
    end
    it "signs an arbitrary string based upon a signature method of HmacSHA256" do
      @id.sign('HmacSHA256',@arbitrary_string).should == @expected_signature
    end
    it "raises an exception if an unsupported signature method is requested" do
      lambda {@id.sign('foo',@arbitrary_string)}.should raise_error(Rubizon::UnsupportedSignatureMethodError)
    end
end
