require 'net/http'
module Rubizon
  module NetworkInterface
    class NetHTTP
      HTTPS_PORT= 443
      HTTP_PORT= 80
      def call(request)
        port= request.scheme=='https' ? HTTPS_PORT : HTTP_PORT
        http= Net::HTTP.new(request.host, port)
        http.use_ssl= true if port == HTTPS_PORT
        r= case request.method
          when 'POST'
            req = Net::HTTP::Post.new(request.path)
            req.form_data = request.query_hash
            http.start {|http| http.request(req) }
          when 'PUT'
            raise 'PUT is not supported'
          when 'DELETE'
            raise 'DELETE is not supported'
          else
            http.start {|http| http.request_get(request.url) }
        end
        Rubizon::StatusAndBody.new(r.code, r.body)
      end
    end
  end
end
