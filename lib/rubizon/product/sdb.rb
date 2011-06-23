module Rubizon
  # Define a class that generates requests for operations on a topic of the
  # Amazon SimpleDB Service (SDB).
  #
  class SimpleDBService < AbstractSig2Product
    # Initialize the SDB interface.  One instance serves one endpoint
    #
    # workers - A Workers object that provides the security credentials,
    #           network interface, and other workers that this
    #           object will use to process requests
    # endpoint    - The endpoint
    def initialize(workers,specs={})
      super(
        {:method=>'GET',
        :scheme=>'https',
        :host=>'sdb.amazonaws.com'}.merge(specs)
      )
      @workers= workers
    end
    
    # List domains
    #
    # max_number_of_domains - (optional) If not specified, the AWS defined limit
    #                         will apply
    # next_token            - (optional) String that tells Amazon SimpleDB where
    #                         to start the next list of domain names
    # Returns an instance of Request
    def list_domains(max_number_of_domains=nil,next_token=nil)
      request= create_request(:ListDomains,ListDomainsResponder)
      request.add_query_elements('MaxNumberOfDomains'=>max_number_of_domains) if max_number_of_domains
      request.add_query_elements('NextToken'=>next_token) if next_token
      request
    end
    class ListDomainsResponder < DefaultResponder
      def initialize(status_and_body)
        super(status_and_body,ArrayResult)
      end
      def process_node(node)
        case node.name
          when '<DomainName'
            @result << node.value
          when '<NextToken'
            @result.meta[:NextToken]= node.value
          else
            super(node)
        end
      end
    end
    
    # Create a domain
    #
    # domain_name - The name of the domain to create
    #
    # Returns an instance of Request
    def create_domain(domain_name)
      request= create_request(:CreateDomain)
      request.add_query_elements('DomainName'=>domain_name)
      request
    end
    
    # Delete a domain
    #
    # domain_name - The name of the domain to delete
    #
    # Returns an instance of Request
    def delete_domain(domain_name)
      request= create_request(:DeleteDomain)
      request.add_query_elements('DomainName'=>domain_name)
      request
    end

    class Domain
      # Work with items within one domain
      #
      # sdb - An instance of the SimpleDBService class
      # arn - Specify the topic's ARN
      def initialize(sdb,name)
        @sdb= sdb
        @domain_name= name
      end
        
      # Add attributes to an item.
      # Although this method's default action is to add attributes, if any
      # given attribute's value responds to (defines a method named) replace_this,
      # the value of that attribute will be replaced.
      #
      # A related methods is:
      #   replace_attribute, whose default action is to replace an attribute's
      #      value.
      #
      # item_name - The name of the item affected
      # attributes - A hash describring the attributes to create or replace.
      #   Multiple values may be added to a given attribute by making the value
      #     of any given element of the hash an array.
      #   If any value in the hash responds to (defines a method named) 
      #     replace_this, the attribute's value will be replaced rather than added.
      #   If the hash responds to (defines a method named) expected, that method
      #     should return a hash that defines the attribute(s) to be checked for
      #     prior existance.  The key is the attribute name.  If the value is 
      #     false, a test will be done to assure that the attribute is not
      #     already defined.  Otherwise a test will be done to assure that the
      #     attribute's value equals the value as a string.  Although the hash
      #     may contain multiple elements, SDB only allows one attribute to be
      #     checked and may return an error if multiple attributes are named.
      #   The AttributesToAdd class simplifies defining attributes that
      #     define an existance test or which combine addition and replacement
      #     attributes.
      def add_attributes(item_name,attributes)
        add_attributes_common(item_name,false,attributes)
      end
      
      # This method is similar to add_attributes except that the default action
      # is to replace attributes rather than add them.
      # The default action can be overridden for any given attribute by defining
      # a method named 'add_attribute' to the value of any element of the hash.
      # This may be done by extending the value with the AddThisAttribute module
      def replace_attributes(item_name,attributes)
        add_attributes_common(item_name,true,attributes)
      end
        
      # Get attributes of an item
      #
      # item_name - The name of the item for which atttributes are to be returned.
      # attribute_names - If unspecified or nil, returns all attributes of the 
      #                     given item.
      #                  If an array, the attribues named in the array are 
      #                     returned.
      #                  Otherwise, the attribute named by the argument is
      #                     returned.  The argument will be converted to a string
      #                     by invoking its to_s method.
      # consistent_read - When true, ensures that the most recent data is 
      #                     returned.
      def get_attributes(item_name,attribute_names=nil,consistent_read=false)
        request= create_item_request(:GetAttributes,item_name)
        request.add_query_elements('ConsistentRead'=>'true') if consistent_read
        if attribute_names
          if attribute_names.respond_to? :each
            attribute_names.each_index do |i| 
              request.add_query_elements("AttributeName.#{i}"=>attribute_names[i].to_s)
            end
          else
            request.add_query_elements("AttributeName"=>attribute_names.to_s)
          end
        end
        request
      end
      
    protected
      def create_request(action,responder_class=DefaultResponder,method=:GET,query_elements=nil)
        @sdb.create_request(action,responder_class,method,query_elements).
          add_query_elements('DomainName'=>@domain_name)
      end

      def create_item_request(action,item_name,responder_class=DefaultResponder,method=:GET,query_elements=nil)
        create_request(action,responder_class=DefaultResponder,method=:GET,query_elements=nil).
          add_query_elements('ItemName'=>item_name)
      end

      def add_attributes_common(item_name,replace,attributes)
        request= create_item_request(:PutAttributes,item_name)
        i= 0
        attributes.each do |k,v|
          request.add_query_elements("Attribute.#{i}.Name"=>k.to_s)
          if replace && !v.respond_to?(:add_attribute) || v.respond_to?(:replace_attribute)
              request.add_query_elements("Attribute.#{i}.Replace"=>'true')
          end
          if v.respond_to? :each
            v.each { |e| request.add_query_elements("Attribute.#{i}.Value"=>e.to_s) }
          else
            request.add_query_elements("Attribute.#{i}.Value"=>v.to_s)
          end
          i+= 1
        end
        if attributes.respond_to?(:expected)
          i= 0
          attributes.expected.each do |k,v|
            request.add_query_elements("Expected.#{i}.Name"=>k.to_s)
            if v
              request.add_query_elements("Expected.#{i}.Value"=>v.to_s)
            else
              request.add_query_elements("Expected.#{i}.Exists"=>'false')
            end
            i+= 1
          end
        end
        request
      end
    end
    
    # Define an interface to a domain.
    #
    # name - The name of the domain
    #
    # Returns a SimpleDBService::Domain object, which includes methods
    # for making requests for items within the given domain.
    def domain(name)
      Domain.new(self,name)
    end
    
  protected
    # Create a Request object that can be used to formulate a single request
    # for this product.
    #
    # Returns an instance of Request
    def create_request(action,responder_class=DefaultResponder,method=:GET,query_elements=nil)
      r= super(@workers,method)
      r.responder_class= responder_class
      r.add_query_elements('Version'=>'2009-04-15','Action'=>action)
      r.add_query_elements(query_elements) if query_elements
      r
    end
  end
  
  # Extend the value of any hash value with this module in order to override the
  # replace_attributes method's default of replacing attributes.
  #
  # For example:
  # domainobj.replace_attributes('itemname',:a=>:b, :c=>'d'.extend(AddThisAttribute))
  module AddThisAttribute
    def add_attribute;true;end
  end                        
  
  # Extend the value of any hash value with this module in order to override the
  # add_attributes method's default of adding attributes.
  #
  # For example:
  # domainobj.add_attributes('itemname',:a=>:b, :c=>'d'.extend(ReplaceThisAttribute))
  module ReplaceThisAttribute
    def replace_attribute;true;end
  end                        
    
  # This is a helper for creating the attributes argument to 
  # the add_attributes and replace_attributes methods.
  #
  # In the simplest case, that argument is simply a hash in which the
  # keys are the attribute names and the corresponding value is that to be
  # added to or replace the current attribute value.
  #
  # But optional treatment can be specified by extending the hash and its
  # values with additional methods.
  #  It is possible to specify some attributes that are to be added or replaced
  #    even when the default treatment is different.  This allows a single
  #    message to SDB to specify both attributes that are to be added and ones
  #    that are to replace existing ones.
  #  It is also possible to specify an attribute that either must not be set
  #    or which must have a specific value before the additions and 
  #    replacements are allowed to procede.  
  class AttributesToAdd < Hash
    def initialize(hash)
      super
      merge! hash
    end
    def add_attribute(name,value)
      self[name]= value.extend(AddThisAttribute)
    end
    def replace_attribute(name,value)
      self[name]= value.extend(ReplaceThisAttribute)
    end
    def must_exist(name,value)
      def this.expected
        {name=>value}
      end
    end
    def must_not_exist(name,value)
      def this.expected
        {name=>false}
      end
    end
  end
end
