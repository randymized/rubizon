require 'cgi'
require File.dirname(__FILE__) + '/request'
module Rubizon
  # An abstract representation of an AWS product whose REST API uses 
  # signature version 2.  This class provides a foundation for
  # classes that represent specific AWS products.
  class AbstractSig2Product
    # Initialization
    #
    # specs -      A Hash containing specifications for the product.
    #              :scheme - (optional) Default scheme is https.  
    #                        May be set to "http".
    #              :ARN    - Required if an ARN is available for the product 
    #                        and an ARN is required in queries by the API.
    #                        In many cases, the host can be deduced from the
    #                        content of the ARN.
    #              :host   - (conditionally required) If an ARN is not
    #                        specified or if the host cannot be properly
    #                        deduced from the ARN, :host must be specified.
    #                        If specified, this will override any host name
    #                        that might be deduced from the ARN.
    #              :path   - (optional) Default path is '/'.  May be set to
    #                        a path that applies to all requests for the 
    #                        product.
    #              :_omit  - (optional) An array containing a list of elements
    #                        that are not to be included in the query string.
    #                        This, for example, can be used in the Product
    #                        Advertising API to suppress the SignatureMethod
    #                        and SignatureVersion parameter/value pairs which
    #                        result from the signing process but are not
    #                        supported in that API
    #              (other) - (optional) Other key/value pairs may be specified.
    #                        These will be included in any query string 
    #                        generated for this product
    def initialize(specs={})
      @scheme= (specs.delete(:scheme) || specs.delete('scheme') || 'https').to_s
      @arn= specs.delete(:ARN) || specs.delete('ARN') || specs.delete(:arn) || specs.delete('arn')
      @host= specs.delete(:host) || specs.delete('host')
      if @arn && !@host
        elems= @arn.split(':',5)
        @host= "#{elems[2]}.#{elems[3]}.amazonaws.com"
      end
      if !@host
        raise InvalidParameterError, 'No host was specified and one could not be deduced from arn specifications'
      end
      @path= specs.delete(:path) || specs.delete('path') || '/'
      @query_elements= specs
      @query_elements['SignatureMethod']= 'HmacSHA256'
      @query_elements['SignatureVersion']= 2
      @query_elements['arn']= @arn if @arn
    end
    
    # Returns the URL scheme, such as http or https
    attr_reader :scheme
    
    # Returns the ARN (Amazon Resource Name) served by this object.
    # Returns nil if an ARN is not defined.
    attr_reader :arn
    
    # Returns the host (domain and subdomains) of the product served by this
    # object.
    attr_reader :host
    
    # Returns the path part of the URL of the product served by this object,
    # typically '/'.
    attr_reader :path
    
    # Returns a Hash containing elements to be included in any query string
    # generated for this product.  To this will be added elements identifying
    # the specific action, the subject of the action, the access key, and
    # elements related to signing the request.
    attr_reader :query_elements
    
    # Returns the product's endpoint.  The endpoint is that part of a URL that
    # includes the scheme, host, and path, but not the query string. 
    # An action may extend the product's path, but otherwise would retain the
    # rest of the endpoint.
    def endpoint
      "#{@scheme}://#{@host}#{@path}"
    end
    
    def create_request(credentials)
      Request.new(credentials,@scheme,@host,@path,@query_elements)
    end

  protected 
    # In most cases, an action method needs only to invoke this method.
    # It will create a Request object, add query elements for the action and
    # its subject and return the request object.  The URL, query string,
    # hostname and other information needed to get (or post, put or delete)
    # a resource from AWS can then be obtained via Request methods.
    def basic_action(action_elements,subject_elements=nil)
      req= create_request(@credentials)
      req.add_action(action_elements,subject_elements)
    end
  end
end
