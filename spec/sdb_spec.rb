require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'xmlsimple'
require 'ruby-debug'

describe "The AWS SimpleDB interface" do
  before do
    @sdb= Rubizon::SimpleDBService.new(TestWorker)
  end
  it "creates a domain"
  it "deletes a domain"
  it "lists domains" do
    Rubizon::make_request(@sdb.list_domains)
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
