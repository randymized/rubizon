module Rubizon
  class StatusAndBody
    attr_reader :status, :body
    def initialize(status,body)
      @status= status.to_i
      @body= body
    end
  end
end
