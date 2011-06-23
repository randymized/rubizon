require 'helper'

class TestSimpleDB < Test::Unit::TestCase
  def is_valid_default_response(r)
    assert r.meta.key?(:BoxUsage)
    assert r.meta.key?(:RequestId)
  end
  def setup
    @sdb= Rubizon::SimpleDBService.new(TestWorker)
  end
  def test_creates_a_domain_makes_sure_it_is_listed_deletes_the_domain_and_confirms_deletion
    r= @sdb.delete_domain(TestDomainName).request
    is_valid_default_response(r)
    
    r= @sdb.list_domains.request
    assert !r.include?(TestDomainName)

    r= @sdb.create_domain(TestDomainName).request
    is_valid_default_response(r)
    
    r= @sdb.list_domains.request
    assert r.include?(TestDomainName)

    r= @sdb.delete_domain(TestDomainName).request
    is_valid_default_response(r)
    
    r= @sdb.list_domains.request
    assert !r.include?(TestDomainName)
  end
  def test_deletes_a_domain
    skip
  end
  def test_lists_domains
    r= @sdb.list_domains.request
    assert r.kind_of?(Array)
    assert r.meta.key?(:BoxUsage)
    assert r.meta.key?(:RequestId)
  end
  def test_gets_a_domains_metadata
    skip
  end
  def test_creates_an_item
    skip
  end
  def test_adds_attributes_to_an_item
    skip
  end
  def test_replaces_attributes_of_an_item
    skip
  end
  def test_both_adds_and_replaces_attributes_of_an_item
    skip
  end
  def test_adds_attributes_to_an_item_and_checks_that_an_existing_attribute_has_not_changed_in_the_interim
    skip
  end
  def test_tries_to_add_attributes_to_an_item_but_fails_because_one_of_the_attributes_has_changed
    skip
  end
  def test_deletes_some_attributes_of_an_item
    skip
  end
  def test_deletes_all_attributes_of_an_item
    skip
  end
  def test_adds_attributes_to_several_items_in_one_database_request
    skip
  end
  def test_uses_a_select_expression_to_retrive_some_items
    skip
  end
end
