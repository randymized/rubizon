module Rubizon
  class RubizonError < StandardError; end
  class UnsupportedSignatureMethodError < StandardError; end
  class UnsupportedSignatureVersionError < StandardError; end
  class InvalidParameterError < RubizonError
    attr_reader :message
    def initialize(message='An invalid parameter is in the request')
      @message= message
    end
  end
end
