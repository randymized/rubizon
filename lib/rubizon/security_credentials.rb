require 'hmac-sha2'
require 'base64'
require File.dirname(__FILE__) + '/exceptions'
module Rubizon
  class SecurityCredentials
    attr_reader :accessID
    def initialize(accessID, secretID)
      @accessID= accessID
      @secretID= secretID
    end
    def sign256(string_to_sign)
      @hmac256||= HMAC::SHA256.new(@secretID)
      @hmac256.update(string_to_sign)
      Base64.encode64(@hmac256.digest).chomp
    end
    def sign(signature_method,string_to_sign)
      case signature_method
        when 'HmacSHA256'
          sign256(string_to_sign)
        else
          raise UnsupportedSignatureMethodError, "The #{signature_method} signature method is not supported"
        end
    end
  end
end