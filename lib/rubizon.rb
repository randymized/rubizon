require File.dirname(__FILE__) + '/rubizon/security_credentials'
require File.dirname(__FILE__) + '/rubizon/workers'
require File.dirname(__FILE__) + '/rubizon/request'
require File.dirname(__FILE__) + '/rubizon/errors'
module Rubizon
  autoload :Version, File.dirname(__FILE__) + '/rubizon/version'
  autoload :AbstractSig2Product, File.dirname(__FILE__) + '/rubizon/abstract_sig2_product'
  autoload :ProductAdvertisingProduct, File.dirname(__FILE__) + '/rubizon/product/product_advertising'
  autoload :SimpleNotificationService, File.dirname(__FILE__) + '/rubizon/product/sns'
  autoload :SimpleDBService, File.dirname(__FILE__) + '/rubizon/product/sdb'
end
