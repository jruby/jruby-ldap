require 'test/unit'
require 'setup'

class TestSearch < Test::Unit::TestCase
  def setup
    @conn = LDAP::Conn.new($LDAP_test_host, $LDAP_test_port)
    @conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    @conn.bind($LDAP_test_username, $LDAP_test_password)
  end
  
  def teardown
    @conn.unbind rescue nil
  end

  def test_simple_base_search
    found = 0
    @conn.search('o=ruby_ldap_test_tree', LDAP::LDAP_SCOPE_BASE, "(objectClass=*)", []) do |v|
      found += 1

      assert_equal 'o=ruby_ldap_test_tree', v.get_dn
      assert_equal ['o', 'objectClass'].sort, v.get_attributes.sort
      assert_equal ['ruby_ldap_test_tree'], v['o']
      assert_equal ['organization'], v['objectClass']
      assert_equal ['organization'], v['OBJECTCLASS']
    end
    
    assert_equal 1,found
  end

  def test_simple_one_level_search
    found = 0
    @conn.search('o=ruby_ldap_test_tree', LDAP::LDAP_SCOPE_ONELEVEL, "(objectClass=*)", []) do |v|
      found += 1

      assert_equal 'o=sub_tree,o=ruby_ldap_test_tree', v.get_dn
      assert_equal ['o', 'objectClass'].sort, v.get_attributes.sort
      assert_equal ['sub_tree'], v['o']
      assert_equal ['organization'], v['objectClass']
      assert_equal ['organization'], v['OBJECTCLASS']
    end
    
    assert_equal 1,found
  end

  def test_simple_subtree_search
    found = 0

    @conn.search('o=ruby_ldap_test_tree', LDAP::LDAP_SCOPE_SUBTREE, "(objectClass=*)", []) do |v|
      found += 1
      if v.get_dn =~ /sub_tree/
        assert_equal 'o=sub_tree,o=ruby_ldap_test_tree', v.get_dn
        assert_equal ['o', 'objectClass'].sort, v.get_attributes.sort
        assert_equal ['sub_tree'], v['o']
        assert_equal ['organization'], v['objectClass']
        assert_equal ['organization'], v['OBJECTCLASS']
      else
        assert_equal 'o=ruby_ldap_test_tree', v.get_dn
        assert_equal ['o', 'objectClass'].sort, v.get_attributes.sort
        assert_equal ['ruby_ldap_test_tree'], v['o']
        assert_equal ['organization'], v['objectClass']
        assert_equal ['organization'], v['OBJECTCLASS']
      end
    end
    
    assert_equal 2,found
  end

  def test_filter
    found = 0

    @conn.search('o=ruby_ldap_test_tree', LDAP::LDAP_SCOPE_SUBTREE, "(o=sub_tree)", []) do |v|
      found += 1

      assert_equal 'o=sub_tree,o=ruby_ldap_test_tree', v.get_dn
      assert_equal ['o', 'objectClass'].sort, v.get_attributes.sort
      assert_equal ['sub_tree'], v['o']
      assert_equal ['organization'], v['objectClass']
      assert_equal ['organization'], v['OBJECTCLASS']
    end
    
    assert_equal 1,found
  end

  def test_attributes
    assert_exists_in_ldap 'o=sub_tree,o=ruby_ldap_test_tree', {'objectClass' => ['organization'] }
  end
end
