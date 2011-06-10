require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SimpleNotificationService" do
    before do
      @access_key= '00000000000000000000'
      @credentials= Rubizon::SecurityCredentials.new(@access_key,'1234567890')
      @arn= 'arn:aws:sns:us-east-1:123456789:My-Topic'
      @host= 'sns.us-east-1.amazonaws.com'
      @snsProduct= Rubizon::SimpleNotificationService.new(@credentials,@host)
    end
    it "formulates a url that will publish a message to a topic" do
      message= 'hello world'
      req= @snsProduct.topic(@arn).publish(message)
      req.endpoint.should == "http://#{@host}/"
      q= CGI::parse(req.query_string)
      q['SignatureVersion'].first.should == '2'
      q['SignatureMethod'].first.should == 'HmacSHA256'
      q['Signature'].first.should be_a(String)
      CGI::unescape(q['Signature'].first).length.should == 44
      q['AWSAccessKeyId'].first.should == @access_key
      q.should have_key('Timestamp')
      q['Action'].first.should == 'Publish'
      CGI::unescape(q['TopicArn'].first).should == @arn
      CGI::unescape(q['Message'].first).should == message
      q.should_not have_key('Subject')
    end
    it "formulates a url that will publish a message and a subject to a topic" do
      message= 'world'
      subject= 'An important word'
      req= @snsProduct.topic(@arn).publish(message,subject)
      q= CGI::parse(req.query_string)
      q['Action'].first.should == 'Publish'
      CGI::unescape(q['TopicArn'].first).should == @arn
      CGI::unescape(q['Message'].first).should == message
      CGI::unescape(q['Subject'].first).should == subject
    end
end
