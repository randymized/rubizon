require 'helper'

class TestSecurityCredentials < Test::Unit::TestCase
    def setup
      @id= Rubizon::SecurityCredentials.new(ExampleAWSAccessKeyId,ExampleSecretAccessKeyId)
      @arbitrary_string= 'x'
      @expected_signature= '6KClHg2k6AiXNRwaLa7sC7LIxP4NkUieZheem0eHnBI='
    end
    def test_reports_the_access_key_ID
      assert_equal(ExampleAWSAccessKeyId, @id.accessID)
    end
    def test_wont_allow_accessing_the_secret_access_key_ID
      assert !@id.respond_to?(:secretID)
      assert !@id.respond_to?(:secretKeyID)
      assert !@id.respond_to?(:secretAccessKeyID)
      assert !@id.respond_to?(:awsSecretAccessKeyID)
    end
    def test_signs_an_arbitrary_string_using_the_secretID
      assert_equal(@expected_signature, @id.sign256(@arbitrary_string))
    end
    def test_produces_a_different_signature_if_initialized_with_a_different_access_key
      assert_not_equal(@expected_signature, Rubizon::SecurityCredentials.new(ExampleAWSAccessKeyId,ExampleSecretAccessKeyId+'x').sign256(@arbitrary_string))
    end
    def test_signs_an_arbitrary_string_based_upon_a_signature_method_of_HmacSHA256
      assert_equal(@expected_signature, @id.sign('HmacSHA256',@arbitrary_string))
    end
    def test_raises_an_exception_if_an_unsupported_signature_method_is_requested
      assert_raise(Rubizon::UnsupportedSignatureMethodError) do
        @id.sign('foo',@arbitrary_string)
      end
    end
end
