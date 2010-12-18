require 'cgi'
require File.dirname(__FILE__) + "/../abstract_sig2_product"
module Rubizon
  # Define a class that generates requests for operations on the Product
  # Advertising API
  #
  class ProductAdvertisingProduct < AbstractSig2Product
    # Initialize the product interface.
    #
    # credentials - A SecurityCredentials object that encapsulates the
    #               access and secret ids to be used for this product.
    # scheme      - (optional - default: http) May set to 'https' if supported.
    def initialize(credentials,scheme='http')
      super(
        :scheme=>'http',
        :host=>'webservices.amazon.com',
        :path=>'/onca/xml',
        '_omit' => ['SignatureMethod','SignatureVersion'],
        'Service'=>'AWSECommerceService'
      )
      @credentials= credentials
    end

    # Create a request for an item lookup.  The URL to use may be obtained
    # from the request.
    #
    # params - Parameters for the specific request as key/value pairs.
    def item_lookup_request(subject_elements={})
      basic_action(
        @item_lookup_elements||= {'Operation'=>'ItemLookup'},
        subject_elements
      )
    end
  end
end
