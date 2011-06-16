module Rubizon
  # Define a class that generates requests for operations on the Product
  # Advertising API
  #
  class ProductAdvertisingProduct < AbstractSig2Product
    # Initialize the product interface.
    #
    # workers - A Workers object that provides the security credentials,
    #           network interface and other workers that this
    #           object will use to process requests
    # scheme  - (optional - default: http) May set to 'https' if supported.
    def initialize(workers,scheme='http')
      super(
        :scheme=>scheme,
        :host=>'webservices.amazon.com',
        :path=>'/onca/xml',
        '_omit' => ['SignatureMethod','SignatureVersion'],
        'Service'=>'AWSECommerceService'
      )
      @workers= workers
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
