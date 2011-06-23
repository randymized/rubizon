require 'libxml'
module Rubizon
  
  # Represents a single XML node, such as the start or end of an element.
  class XMLNode
    def initialize(reader)
      @reader= reader
    end
    # The name of an node will be that of the tag with an optional prefix.  
    # If this is an opening tag, the name will be prefixed by '<'.
    # If this is a closing tag, the name will be prefixed by '/'.
    def name
      @name ||=
        if @reader.node_type == LibXML::XML::Reader::TYPE_ELEMENT
          '<'+@reader.name
        elsif @reader.node_type == LibXML::XML::Reader::TYPE_END_ELEMENT
          '/'+@reader.name
        else
          @reader.name
        end
    end
    # The value of a leaf element, the text between the opening and closing tags.
    def value
      @reader.read_string
    end
  end
  
  # Reads the nodes of XML.
  # Currently this is a wrapper around LibXML::XML::Reader
  class XMLReader
    def initialize(xml)
      @reader = LibXML::XML::Reader.string(xml)
    end
    def each
      while @reader.read
        yield XMLNode.new(@reader)
      end
    end
  end
end
