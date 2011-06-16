module Rubizon
  # Pull together the various components that are a constant during the lifetime
  # of any given interface and provide concrete implementations of the network
  # interface, XML parser and sign requests with specific credentials.
  class Workers
    attr_reader :credentials,:network_interface
    def initialize(credentials,network_interface=nil)
      @credentials= credentials
      @network_interface= network_interface
    end
  end
end
