require 'hashery'
module Rubizon
  class SimpleResult
    attr_accessor :meta
    def initialize
      @meta= {}
    end
  end
  
  class ArrayResult < Array
    attr_accessor :meta
    def initialize
      @meta= {}
    end
  end
  
  class HashResult < Hash
    attr_accessor :meta
    def initialize
      @meta= {}
    end
  end
  
  class DictionaryResult < Dictionary
    attr_accessor :meta
    def initialize
      @meta= {}
    end
  end
end
