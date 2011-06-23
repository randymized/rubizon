module Rubizon
  class DefaultResponder
    def initialize(status_and_body, result_class=SimpleResult)
      unless status_and_body.status == 200
        raise_alarm(status_and_body)  #we have a problem
      end
      @result= result_class.new
      @reader= XMLReader.new(status_and_body.body)
    end
  
    def respond
      @reader.each do |node|
        process_node(node)
      end
      @result
    end
    def process_node(node)
      case node.name
        when '<RequestId'
          @result.meta[:RequestId]= node.value
        when '<BoxUsage'
          @result.meta[:BoxUsage]= node.value
      end
    end
  protected
    # Invoked if the HTTP result code != 200.
    # Raise an exception!  Some kind of error has occurred.
    def raise_alarm(status_and_body)
      h= {:code=>'Undeciphered',:message=>status_and_body.body}  #define and set throw-away defaults
      reader= LibXML::XML::Reader.string(status_and_body.body)
      while reader.read
        if reader.node_type == LibXML::XML::Reader::TYPE_ELEMENT
          case reader.name
            when 'Code'
              h[:code]= reader.read_string
            when 'Message'
              h[:message]= reader.read_string
          end
        end
      end
      errname= 'AWS'+h[:code]+'Error'
      errclass= status_and_body.status/100 == '5' ? Class.new(Rubizon::AWSServerError) : Class.new(Rubizon::AWSClientError)
      Rubizon.const_set(errname,errclass) unless Rubizon.const_defined?(errname)
      raise Rubizon.const_get(errname).new(h[:message])
    end
  end
end
