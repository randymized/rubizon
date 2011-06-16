require 'net/http'
module Rubizon
  module NetworkInterface
    class NetHTTP
      def call(request)
        r= Net::HTTP.get_response(URI.parse(request.url))
        Rubizon::StatusAndBody.new(r.code, r.body)
      end
    end
  end
end
