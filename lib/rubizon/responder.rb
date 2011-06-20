require 'yaml'
require 'libxml'

module Rubizon
  class Responder
    # Initialize this responder.  Saves YAML, which specifies how XML that is
    # received from AWS is to be transformed, for later interpretation.
    #
    # Lazy interpretation of the YAML avoids interpreting YAML for actions that
    # are never used.
    def initialize(yaml)
      @yaml= yaml
    end
    
    # This is the method that will be invoked whenever XML is received from
    # AWS for the kind of request served by this responder.  It will parse the
    # XML, extract relevant data and place the data into a data structure according
    # to the YAML instructions.
    #
    # xml - the XML received from AWS
    def process(status_and_body)
      unless status_and_body.status == 200
        raise_alarm(status_and_body)  #we have a problem
      end

      #turn the YAML into a set of instructions that will guide the XML interpretation process
      @instructions||= BuildParser.new.analyze(@yaml)
      XMLConverter.new(@instructions).process(status_and_body.body)
    end
    
  protected
    # Invoked if the HTTP result code != 200.  Raise an exception!  
    # Some kind of error has occurred.
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

  class XMLConverter
    class StackItem
      attr_reader :depth, :instructions, :hash
      def initialize(depth, instructions, hash={})
        @depth= depth
        @instructions= instructions
        @hash= hash
      end
    end
    def initialize(instructions)
      @stack= [StackItem.new(-1,instructions)]
    end
    def process(xml)
      @reader = LibXML::XML::Reader.string(xml)
      step
    end
    def step
      while @reader.read
        current= @stack.last
        if @reader.depth <= current.depth
          @stack.pop
          current= @stack.last
        end
        if match= current.instructions[@reader.name]
          instance_eval &match
        end
      end
      @stack[0].hash
    end
  protected
    def subtree(subinstr)
      current= @stack.last
      @stack.push(StackItem.new(@reader.depth,subinstr,current.hash))
      step
    end
    def array_element(array_name)
      if @reader.node_type == LibXML::XML::Reader::TYPE_ELEMENT
        (@stack.last.hash[array_name]||= []) << @reader.read_string
      end
    end
    def kv
      if @reader.node_type == LibXML::XML::Reader::TYPE_ELEMENT
        @stack.last.hash[@reader.name]= @reader.read_string
      end
    end
  end
  
  class BuildParser
    def analyze(yaml)
      instructions= {}
      sub(YAML::load(yaml), instructions)
      instructions
    end
    def sub(hash, instructions)
      hash.each do |key,node|
        if node.is_a? Hash
          subinstr= {}
          instructions[key]= Proc.new {subtree(subinstr)}
          sub(node, subinstr)
        else
        a= node.split
          case a.first
            when 'element'
              name= a[1] || key
              instructions[key]= Proc.new {array_element(name)}
            when 'kv'
              instructions[key]= Proc.new {kv}
          end
        end
      end
    end
  end
end
