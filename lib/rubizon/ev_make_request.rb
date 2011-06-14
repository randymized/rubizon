#make a request using EventMachine::HttpRequest and process the response.
module Rubizon
  def self.make_request(request)
    debugger
    http= EventMachine.synchrony do
      http= EventMachine::HttpRequest.new(request.endpoint).
        get(:timeout => 10, :query=>request.query_string)
      debugger
      @response= request.responder.call(http.response_header.status,http.response)
    end
  end
end
