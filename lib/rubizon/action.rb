require 'cgi'
module Rubizon
  # Defines an action that may be performed on an AWS product.
  # This class provides a common base for building product methods.
  # The class should only contain static data so that a single instance can
  # be used to serve all requests for the given object.
  class Action
    # Initialize the action.
    #
    # query_elements - A hash of key/value pairs to be included in the 
    #                  query string for all requests of this action.  The set
    #                  of pairs should only define the action.  Further pairs
    #                  may need to be added to this set at the time of each
    #                  request in order to specify the object of the action.
    def initialize(query_elements={})
      @query_elements= query_elements
      @append_this_to_path= ''
    end

    # Get the query elements, i.e. the set of key/value pairs that define the
    # action.
    attr_reader :query_elements

    # Define additional path elements that are to be appended to the product's
    # path.
    #
    # path_elements - The path elements to be added
    def append_this_to_path=(path_elements)
      @append_this_to_path= path_elements
    end
    
    # Returns a String that is to be appended to the end of the product's path.
    attr_reader :append_this_to_path
  end
end
