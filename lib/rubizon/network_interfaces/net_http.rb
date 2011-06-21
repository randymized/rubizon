require 'net/http'
module Rubizon
  module NetworkInterface
    class NetHTTP
      def call(request)
        r= case request.method
          when 'POST'
            Net::HTTP.post_form(URI.parse(request.endpoint),request.query_hash)
          when 'PUT'
            raise 'PUT is not supported'
          when 'DELETE'
            raise 'DELETE is not supported'
          else
            Net::HTTP.get_response(URI.parse(request.url))
        end
        Rubizon::StatusAndBody.new(r.code, r.body)
      end
    end
  end
end
