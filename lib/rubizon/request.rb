require 'cgi'
module Rubizon
  # Represents a request to be made to AWS.
  #
  # Starts with credentials, workers and specifications for the product, 
  # such as its ARN, elements of its URL and query elements.  
  # To this is added specifications for the specific action to be performed.
  # 
  # Request builds a URL for the action and signs the request.  It then
  # makes the entire URL and various components of it available for whatever
  # transport mechanism is to be used.
  #
  # A new instance of Request is to be created for each request sent to AWS
  class Request
    # Initialize the request.
    #
    # workers - A Workers object that provides the security credentials,
    #           network interface and other workers that this
    # scheme         - The scheme to be used: 'http' or 'https'
    # host           - The name of the HTTP host to serve this request
    # path           - The URL path, typically '/'.
    # query_elements - A hash of key/value pairs to be included in the 
    #                  query string.  
    #                _omit - If an element with a key of '_omit' is included,
    #                        the value must be an array containing names of keys
    #                        to be omitted from the query_elements array before
    #                        the request is signed and the query string formed.
    #                        This allows allowing SignatureMethod or 
    #                        SignatureVersion to be specified, even if they are
    #                        not to be included in the query string.
    #                SignatureVersion - The signature version to be used, such
    #                        as 1 or 2.  This should be a numeric value.  If not
    #                        present, signature version 1 is implied.
    #                SignatureMethod - The signature methods defined for version
    #                        two are HmacSHA256 and HmacSHA1.
    def initialize(workers,method,scheme,host,path,query_elements={})
      if path.is_a? Hash
        # Method was an addition to the argument list.  Detect invocations where
        # method was not specified and adjust accordingly.
        query_elements= path
        path= host
        host= scheme
        scheme= method.to_s
        method= 'GET'
      end
      @method= method.to_s.upcase
      @workers= workers
      @credentials= workers.credentials
      @scheme= scheme.to_s
      @host= host
      @path= path
      @query_elements= query_elements.dup
      @responder= nil
    end
    
    # Actually make the request.  Send the message to AWS, receive and parse
    # the response, returning pertinent data in an appropriate format (the
    # responder worker will do the extracting and formatting).
    #
    # Returns whatever data is returned by the responder after processing
    # the response from AWS.
    def request
      responder.process(
        @workers.network_interface.call(self)
      )
    end

    # Specify the class of the responder to use with this request.
    # An instance of that class will be created when a response is received from 
    # AWS as a result of this request.  That responder is then responsible for
    # checking for errors, extracting the useful data form the response and
    # returning the data in a useful and appropriate format.
    #
    # Returns self, to allow chaining of requests.
    def responder=(rf)
      @responder= rf
      self
    end
    
    def responder
      @responder
    end
    
    # Append additional elements to the currently defined path.
    def append_to_path(path)
      @path+= path
    end
    
    # Replace the currently defined path with the one given.
    def path=(path)
      @path= path
    end
    
    # Add key/value pairs to the query_elements.  Typically, these additional
    # elements will be added to specify the action to be taken or subject of
    # that action and parameters of that action or subject.
    #
    # query_elements - A Hash containing key/value pairs to be added to the
    #                  query string.
    #
    # returns self
    def add_query_elements(query_elements)
      @query_elements.merge! query_elements
      self
    end

    # Change the HTTP method
    def method=(method)
      @method= method.to_s.upcase
    end
    
    # Returns the HTTP method, such as GET or POST
    attr_reader :method

    # Returns the URL scheme, such as http or https
    attr_reader :scheme
    
    # Returns the host (domain and subdomains) of the product served by this
    # object.
    attr_reader :host
    
    # Returns the path part of the URL of the product served by this object,
    # typically '/'.
    attr_reader :path
    
    # Returns a hash containing the elements from which a query string would be
    # built.
    attr_reader :query_elements
    
    # Returns the product's endpoint.  The endpoint is that part of a URL that
    # includes the scheme, host, and path, but not the query string. 
    # An action may extend the product's path, but otherwise would retain the
    # rest of the endpoint.
    def endpoint
      @endpoint||= "#{@scheme}://#{@host}#{@path}"
    end
    
    # Create a query string from a hash and sign it.
    # The signature algorithm will be determined from the query elements,
    # such as SignatureVersion
    #
    # The query string, once created, is immutable.
    def query_string(method='GET')
      return @query_string ||=
        if @query_elements['SignatureVersion'].to_i == 2
          query_string_sig2(method).collect { |key, value| [url_encode(key), url_encode(value)].join("=") }.join('&') # order doesn't matter for the actual request
        else
          raise UnsupportedSignatureVersionError, 'Only signature version 2 requests are supported at this time'
        end
    end
    
    
    # Return a signed hash that includes all elements that would be in a query string.
    #
    # The query hash, once created, is immutable.
    def query_hash(method='POST')
      return @query_hash ||=
        if @query_elements['SignatureVersion'].to_i == 2
          query_string_sig2(method)
        else
          raise UnsupportedSignatureVersionError, 'Only signature version 2 requests are supported at this time'
        end
    end
    
    # Returns the full URL 
    #
    # The query string portion of the URL, once created, is immutable.
    def url
      endpoint+'?'+query_string
    end
    
    # An artifact of the signature version 2 signing process:
    # The query string portion of the string to sign.  
    # This is of possible debugging value.
    attr_reader :canonical_querystring

    # An artifact of the signature version 2 signing process:
    # The string that is used to calculate the signature.   
    # This is of possible debugging value.
    attr_reader :string_to_sign
      
    protected
    # Create a query string and sign it using the signature version 2 algorithm.
    def query_string_sig2(method='GET')
      @query_elements['Timestamp']= Time::at(Time.now).utc.strftime("%Y-%m-%dT%H:%M:%S.000Z") unless @query_elements['Timestamp']
      @query_elements['AWSAccessKeyId']= @credentials.accessID
      signature_method= @query_elements['SignatureMethod']
      if @query_elements['_omit']
        @query_elements['_omit'].each do |k|
          @query_elements.delete k
        end
        @query_elements.delete '_omit'
      end
      values = @query_elements.keys.sort.collect {|key|  [url_encode(key), url_encode(@query_elements[key])].join("=") }
      @canonical_querystring= values.join("&")
      @string_to_sign = <<"____".rstrip
#{method}
#{URI::parse(endpoint).host}
#{URI::parse(endpoint).path}
#{@canonical_querystring}
____
      signature= @credentials.sign(signature_method,@string_to_sign)
      @query_elements['Signature'] = signature
      @query_elements
    end
    def url_encode(string)
      string = string.to_s
      # It's kind of like CGI.escape, except CGI.escape is encoding a tilde when
      # it ought not to be, so we turn it back. Also space NEEDS to be %20 not +.
      return CGI.escape(string).gsub("%7E", "~").gsub("+", "%20")
    end
  end
end
