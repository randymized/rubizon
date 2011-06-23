require 'helper'

class TestNetHTTPNetworkInterface < Test::Unit::TestCase
  def a_test(method,scheme)
    @sdb= Rubizon::SimpleDBService.new(TestWorker,:method=>method,:scheme=>scheme)
    request= @sdb.list_domains
    request.method= method
    assert_equal(method.to_s, request.method)
    assert_equal(scheme.to_s, request.scheme)
    r= Rubizon::NetworkInterface::NetHTTP.new.call(request)
    assert_equal(200, r.status)
    assert_kind_of(String, r.body)
  end
  def test_sends_http_get
    a_test(:GET,:http);
  end
  def test_sends_https_get
    a_test(:GET,:https);
  end
  def test_sends_http_post
    a_test(:POST,:http);
  end
  def test_sends_https_post
    a_test(:POST,:https);
  end
end
