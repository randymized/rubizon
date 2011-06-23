require 'helper'

class TestSimpleNotificationService < Test::Unit::TestCase
    def setup
      @access_key= '00000000000000000000'
      @credentials= Rubizon::SecurityCredentials.new(@access_key,'1234567890')
      @arn= 'arn:aws:sns:us-east-1:123456789:My-Topic'
      @host= 'sns.us-east-1.amazonaws.com'
      @snsProduct= Rubizon::SimpleNotificationService.new(@credentials,@host)
    end
    def test_formulates_a_url_that_will_publish_a_message_to_a_topic
      message= 'hello world'
      req= @snsProduct.topic(@arn).publish(message)
      assert_equal "http://#{@host}/",req.endpoint
      q= CGI::parse(req.query_string)
      assert_equal '2',q['SignatureVersion'].first
      assert_equal 'HmacSHA256',q['SignatureMethod'].first
      assert_kind_of String,q['Signature'].first
      assert_equal 44,CGI::unescape(q['Signature'].first).length
      assert_equal @access_key,q['AWSAccessKeyId'].first
      assert q.key?('Timestamp')
      assert_equal 'Publish',q['Action'].first
      assert_equal @arn,CGI::unescape(q['TopicArn'].first)
      assert_equal message,CGI::unescape(q['Message'].first)
      assert !q.key?('Subject')
    end
    def test_formulates_a_url_that_will_publish_a_message_and_a_subject_to_a_topic
      message= 'world'
      subject= 'An important word'
      req= @snsProduct.topic(@arn).publish(message,subject)
      q= CGI::parse(req.query_string)
      assert_equal 'Publish',q['Action'].first
      assert_equal @arn,CGI::unescape(q['TopicArn'].first)
      assert_equal message,CGI::unescape(q['Message'].first)
      assert_equal subject,CGI::unescape(q['Subject'].first)
    end
end
