require 'hmac-sha2'
require 'base64'
module Rubizon
    class Identifier
      attr_reader :accessID
      def initialize(accessID, secretID)
        @accessID= accessID
        @secretID= secretID
      end
      def sign256(string_to_sign)
        hmac = HMAC::SHA256.new(@secretID)
        hmac.update(string_to_sign)
        Base64.encode64(hmac.digest).chomp
      end
    end
end