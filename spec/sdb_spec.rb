require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "The AWS SimpleDB interface" do
  def is_valid_default_response(r)
    r.meta.should have_key(:BoxUsage)
    r.meta.should have_key(:RequestId)
  end
  before do
    @sdb= Rubizon::SimpleDBService.new(TestWorker)
  end
  it "creates a domain, makes sure it is listed, deletes the domain and confirms deletion" do
    r= @sdb.delete_domain(TestDomainName).request
    is_valid_default_response(r)
    
    r= @sdb.list_domains.request
    r.should_not include(TestDomainName)

    r= @sdb.create_domain(TestDomainName).request
    is_valid_default_response(r)
    
    r= @sdb.list_domains.request
    r.should include(TestDomainName)

    r= @sdb.delete_domain(TestDomainName).request
    is_valid_default_response(r)
    
    r= @sdb.list_domains.request
    r.should_not include(TestDomainName)
  end
  it "deletes a domain"
  it "lists domains" do
    r= @sdb.list_domains.request
    r.should be_an Array
    r.meta.should have_key(:BoxUsage)
    r.meta.should have_key(:RequestId)
  end
  it "gets a domain's metadata"
  it "creates an item"
  it "adds attributes to an item"
  it "replaces attributes of an item"
  it "both adds and replaces attributes of an item"
  it "adds attributes to an item and checks that an existing attribute has not changed in the interim"
  it "tries to add attributes to an item but fails because one of the attributes has changed"
  it "deletes some attributes of an item"
  it "deletes all attributes of an item"
  it "adds attributes to several items in one database request"
  it "uses a select expression to retrive some items"
end
