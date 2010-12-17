require 'cgi'
module Rubizon
  # Represents a request to be made to AWS.
  #
  # Starts with specifications for the product, such as its ARN, elements
  # of its URL and query elements.  To this is added access credentials and
  # specifications for the specific action to be performed.
  # 
  # Request builds a URL for the action and signs the request.  It then
  # makes the entire URL and various components of it available for whatever
  # transport mechanism is to be used.
  class Request
    # Initialization
    #
    # identifier - A Rubizon::Identifier object that encapsulates an AWS key
    #              pair.  It will be used to sign the request.
    # specs -      A Hash containing specifications for the product.
    #              :scheme - (optional) Default scheme is http.  
    #                        May be set to "https".
    #              :ARN    - Required if an ARN is available for the product 
    #                        and an ARN is required in queries by the API.
    #                        In many cases, the host can be deduced from the
    #                        content of the ARN.
    #              :host   - (conditionally required) If an ARN is not
    #                        specified or if the host cannot be properly
    #                        deduced from the ARN, :host must be specified.
    #              :path   - (optional) Default path is '/'.  May be set to
    #                        a path that applies to all requests for the 
    #                        product.
    def initialize(identifier,scheme,host,path,query_elements={})
      @identifier= identifier
      @scheme= scheme
      @host= host
      @path= path
      @query_elements= query_elements
    end
    
    def append_to_path(path='')
      @path+= path
    end
    
    def path=(path='')
      @path= path
    end
    
    def add_action_query_elements(query_elements)
      @query_elements.merge! query_elements
    end

    # Returns the URL scheme, such as http or https
    attr_reader :scheme
    
    # Returns the host (domain and subdomains) of the product served by this
    # object.
    attr_reader :host
    
    # Returns the path part of the URL of the product served by this object,
    # typically '/'.
    attr_reader :path
    
    # Returns the product's endpoint.  The endpoint is that part of a URL that
    # includes the scheme, host, and path, but not the query string. 
    # An action may extend the product's path, but otherwise would retain the
    # rest of the endpoint.
    def endpoint
      @endpoint||= "#{@scheme}://#{@host}#{@path}"
    end
    
    # Create a query string from a hash and sign it.
    def query_string
      @query_elements['Timestamp']= Time::at(Time.now).utc.strftime("%Y-%m-%dT%H:%M:%S.000Z") unless @query_elements['Timestamp']
      @query_elements['AWSAccessKeyId']= @identifier.accessID
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
GET
#{URI::parse(endpoint).host}
#{URI::parse(endpoint).path}
#{@canonical_querystring}
____
      signature= @identifier.sign(signature_method,@string_to_sign)
      @query_elements['Signature'] = signature
      @query_elements.collect { |key, value| [url_encode(key), url_encode(value)].join("=") }.join('&') # order doesn't matter for the actual request
    end
    
    def url
      endpoint+'?'+query_string
    end
    
    # An artifact of the signing process: the query string portion of the 
    # string to sign.  This is of possible debugging value.
    attr_reader :canonical_querystring

    # An artifact of the signing process: the string that is used to calculate
    # the signature.   This is of possible debugging value.
    attr_reader :string_to_sign
      
    protected
    def url_encode(string)
      string = string.to_s
      # It's kind of like CGI.escape, except CGI.escape is encoding a tilde when
      # it ought not to be, so we turn it back. Also space NEEDS to be %20 not +.
      return CGI.escape(string).gsub("%7E", "~").gsub("+", "%20")
    end
  end
end
