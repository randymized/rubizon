module Rubizon
  RubizonError= Class.new(StandardError)
  UnsupportedSignatureMethodError= Class.new(RubizonError)
  UnsupportedSignatureVersionError= Class.new(RubizonError)
  class InvalidParameterError < RubizonError
    attr_reader :message
    def initialize(message='An invalid parameter is in the request')
      @message= message
    end
  end

  # superclasses for error results returned from AWS.  A subclass will be
  # dynamically created when an error response is received from AWS.
  AWSClientError= Class.new(RubizonError)  # should not be retried until problem is corrected
  AWSServerError= Class.new(RubizonError)  # may be retried
end
