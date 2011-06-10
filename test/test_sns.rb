require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleNotificationService" do
  @@access_key= '00000000000000000000'
  @@credentials= Rubizon::SecurityCredentials.new(@@access_key,'1234567890')
  @@arn= 'arn:aws:sns:us-east-1:123456789:My-Topic'
  @@host= 'sns.us-east-1.amazonaws.com'
  @@snsProduct= Rubizon::SimpleNotificationService.new(@@credentials,@@host)
    it "formulates a url that will publish a message to a topic" do
      message= 'hello world'
      req= @@snsProduct.topic(@@arn).publish(message)
      assert_equal "http://#{@@host}/", req.endpoint
      q= CGI::parse(req.query_string)
      assert_equal '2', q['SignatureVersion'].first
      assert_equal 'HmacSHA256', q['SignatureMethod'].first
      assert q['Signature'].first.is_a?(String)
      assert_equal 44, CGI::unescape(q['Signature'].first).length
      assert_equal @@access_key, q['AWSAccessKeyId'].first
      assert q.has_key?('Timestamp')
      assert_equal 'Publish', q['Action'].first
      assert_equal @@arn, CGI::unescape(q['TopicArn'].first)
      assert_equal message, CGI::unescape(q['Message'].first)
      assert !q.has_key?('Subject')
    end
    it "formulates a url that will publish a message and a subject to a topic" do
      message= 'world'
      subject= 'An important word'
      req= @@snsProduct.topic(@@arn).publish(message,subject)
      q= CGI::parse(req.query_string)
      assert_equal 'Publish', q['Action'].first
      assert_equal @@arn, CGI::unescape(q['TopicArn'].first)
      assert_equal message, CGI::unescape(q['Message'].first)
      assert_equal subject, CGI::unescape(q['Subject'].first)
    end
end
