require 'cgi'
module Rubizon
    # An abstract representation of an AWS product, providing a foundation for
    # classes that represent specific AWS products.
    class AbstractProduct
      attr_reader :base_url
      
      # An artifact of the signing process: the query string portion of the 
      # string to sign.  This is of possible debugging value.
      attr_reader :canonical_querystring

      # An artifact of the signing process: the string that is used to calculate
      # the signature.   This is of possible debugging value.
      attr_reader :string_to_sign
      
      # Initialization
      #
      # specs - A Hash containing specifications for the product.
      #         - :ARN - If an ARN is available for the product it should be specified
      #                  For some products, the URL can be deduced from the ARN.
      #                  If not, it can be specified.
      #         - :URL - The base URL to be used.  This is optional if an ARN or host
      #                  is specified.  It will override any URL deduced
      #                  from the ARN or host.
      #         - :host   - If host is specified, but not URL, the URL will
      #                     be "http(s)://#{host}/"
      #         - :scheme - The default scheme is http.  You may specify https
      #                     instead.  The scheme is ignored if a URL is 
      #                     specifically specified.
      def initialize(specs={})
        @base_url= specs[:URL] || specs['URL'] || specs[:url] || specs['url']
        @arn= specs[:ARN] || specs['ARN'] || specs[:arn] || specs['arn']
        unless @base_url
          scheme= (specs[:scheme] || specs['scheme'] || 'http').to_s
          if host= specs[:host] || specs['host']
            @base_url= "#{scheme}://#{host.to_s}/"
          elsif @arn
            elems= @arn.split(':',5)
            @base_url= "#{scheme}://#{elems[2]}.#{elems[3]}.amazonaws.com/"
          else
            raise InvalidParameterError, 'No URL was specified and one could not be deduced from host or arn specifications'
          end
        end
      end
      
      # Create a query string from a hash and sign it.
      # 
      # identifier - a Rubizon::Identifier object encapsulating a AWS key pair
      # params     - a Hash containing parameters to be included in the query
      #              string.  To this will be added the ARN, if any, the access
      #              key, the signature and its method and version.  
      #              If a Timestamp element is not provided, one containing the
      #              current time will also be added.
      #            Action - Most products will need an Action element in params.
      def query_string(identifier,params={})
        params= for_query_hash.merge params
        params['Timestamp']= Time::at(Time.now).utc.strftime("%Y-%m-%dT%H:%M:%S.000Z") unless params['Timestamp']
        params['AWSAccessKeyId']= identifier.accessID
        signature_method= params['SignatureMethod']
        if params['_omit']
          params['_omit'].each do |k|
            params.delete k
          end
          params.delete '_omit'
        end
        values = params.keys.sort.collect {|key|  [url_encode(key), url_encode(params[key])].join("=") }
        @canonical_querystring= values.join("&")
        @string_to_sign = <<"____".rstrip
GET
#{URI::parse(@base_url).host}
#{URI::parse(@base_url).path}
#{@canonical_querystring}
____
        signature= identifier.sign(signature_method,@string_to_sign)
        params['Signature'] = signature
        params.collect { |key, value| [url_encode(key), url_encode(value)].join("=") }.join('&') # order doesn't matter for the actual request
      end
      
    protected
    # Get elements that need to be added to the hash from which the query string
    # is created.
    #
    # Returns a Hash containing any elements that should be merged into the hash
    # that is used to form the query string
    def for_query_hash
      h= {
        'SignatureMethod' => 'HmacSHA256',
        'SignatureVersion' => 2,
      }
      h['TopicArn']= @arn if @arn
      h
    end

    def url_encode(string)
      string = string.to_s
      # It's kinda like CGI.escape, except CGI.escape is encoding a tilde when
      # it ought not to be, so we turn it back. Also space NEEDS to be %20 not +.
      return CGI.escape(string).gsub("%7E", "~").gsub("+", "%20")
    end
  end
end
