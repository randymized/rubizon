require File.dirname(__FILE__) + '/rubizon/security_credentials'
require File.dirname(__FILE__) + '/rubizon/request'
module Rubizon
  autoload :AbstractSig2Product, File.dirname(__FILE__) + '/rubizon/abstract_sig2_product'
  autoload :ProductAdvertisingProduct, File.dirname(__FILE__) + '/rubizon/product/product_advertising'
  autoload :SimpleNotificationService, File.dirname(__FILE__) + '/rubizon/product/sns'
end
