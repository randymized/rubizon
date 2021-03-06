require 'helper'

class TestSecurityCredentials < Test::Unit::TestCase
  context "A SecurityCredentials instance" do
    setup do
      @id= Rubizon::SecurityCredentials.new(AWSAccessKeyId,SecretAccessKeyId)
      @arbitrary_string= 'x'
      @expected_signature= '6KClHg2k6AiXNRwaLa7sC7LIxP4NkUieZheem0eHnBI='
    end
    should "report the access key ID" do
      assert_equal AWSAccessKeyId, @id.accessID
    end
    should "not allow accessing the secret access key ID" do
      assert !@id.respond_to?(:secretID)
      assert !@id.respond_to?(:secretKeyID)
      assert !@id.respond_to?(:secretAccessKeyID)
      assert !@id.respond_to?(:awsSecretAccessKeyID)
    end
    should "sign an arbitrary string using the secretID" do
      assert_equal @expected_signature, @id.sign256(@arbitrary_string)
    end
    should "produce a different signature if initialized with a different access key" do
      assert_not_equal @expected_signature, Rubizon::SecurityCredentials.new(AWSAccessKeyId,SecretAccessKeyId+'x').sign256(@arbitrary_string)
    end
    should "sign an arbitrary string based upon a signature method of HmacSHA256" do
      assert_equal @expected_signature, @id.sign('HmacSHA256',@arbitrary_string)
    end
    should "raise an exception if an unsupported signature method is requested" do
      assert_raise(Rubizon::UnsupportedSignatureMethodError) do
        @id.sign('foo',@arbitrary_string)
      end
    end
  end
end
