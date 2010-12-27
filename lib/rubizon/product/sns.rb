require 'cgi'
require File.dirname(__FILE__) + "/../abstract_sig2_product"
module Rubizon
  # Define a class that generates requests for operations on a topic of the
  # Simple Notification Service (SNS).
  #
  class SimpleNotificationService < AbstractSig2Product
    # Initialize the SNS interface.  Each instance supports requests to one
    # topic.
    #
    # credentials - A SecurityCredentials object that encapsulates the
    #               access and secret ids to be used for this product.
    # arn         - The topic served by this object
    # scheme      - (optional - default: http) May set to 'https' if supported.
    def initialize(credentials,host,scheme='http')
      super(
        :scheme=>scheme,
        :host=>host
      )
      @credentials= credentials
    end
    
    # Create a Request object that can be used to formulate a single request
    # for this product.
    #
    # Returns an instance of Request
    def create_request
      super(@credentials)
    end

    class Topic
      # Specify the topic.
      #
      # sns - An instance of the SimpleNotificationService class
      # arn - Specify the topic's ARN
      def initialize(sns,arn)
        @sns= sns
        @arn= arn
      end
        
      # Publish a message to the topic.
      #
      # message - The message you want to send to the topic.
      # subject - Optional parameter to be used as the "Subject" line of when the message is delivered to e-mail endpoints.
      #
      # Returns the Request object.  The url, and its elements may be obtained
      # from the returned request object.
      def publish(message,subject=nil)
        request= create_request
        request.add_query_elements('Action'=>'Publish','Message'=>message)
        request.add_query_elements('Subject'=>subject) if subject
        request
      end
      
    protected
      def create_request
        @sns.create_request.add_query_elements('TopicArn'=>@arn)
      end
    end
    
    # Define a topic.
    #
    # arn - The ARN of the topic
    #
    # Returns a SimpleNotificationService::Topic object, which includes methods
    # for making requests of and for the topic.
    def topic(arn)
      Topic.new(self,arn)
    end
  end
end
