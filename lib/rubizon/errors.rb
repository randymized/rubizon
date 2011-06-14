module Rubizon
  AWSClientError= Class.new(StandardError)  # should not be retried until problem is corrected
  AWSServerError= Class.new(StandardError)  # may be retried
end
