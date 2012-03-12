require 'rubygems'
require 'bundler/setup'
require 'ldap'
require './username_and_password'

$LDAP_test_host = 'localhost'
$LDAP_test_port = LDAP::LDAP_PORT

def delete_tree(c, name)
  c.search(name, LDAP::LDAP_SCOPE_ONELEVEL, "(objectClass=*)", ['dn']) do |v|
    delete_tree c, v.get_dn
  end rescue nil
  c.delete(name)
end


c = LDAP::Conn.new($LDAP_test_host, $LDAP_test_port)
c.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
c.bind($LDAP_test_username, $LDAP_test_password) do 
  # just clean out and create our tree

  delete_tree(c, 'o=ruby_ldap_test_tree') 
  
  c.add('o=ruby_ldap_test_tree', {'objectClass' => ['organization'], 'o' => ['ruby_ldap_test_tree']})
  c.add('o=sub_tree, o=ruby_ldap_test_tree', {'objectClass' => ['organization'], 'o' => ['sub_tree']})
end


module Test::Unit::Assertions
  def assert_exists_in_ldap dn, attrs = {}
    found = 0
    @conn.search(dn, LDAP::LDAP_SCOPE_BASE, "(objectClass=*)", attrs.keys) do |entry|
      found += 1

      assert_equal dn, entry.get_dn
      assert_equal attrs.keys.sort, entry.get_attributes.sort unless attrs == { }
      attrs.each do |k,v|
        assert_equal v, entry[k]
        assert_equal v, entry[k.downcase]
        assert_equal v, entry[k.upcase]
      end
    end
    
    assert_equal 1,found
  end

  def assert_dont_exists_in_ldap dn
    assert_raises(LDAP::ResultError) do 
      @conn.search(dn, LDAP::LDAP_SCOPE_BASE, "(objectClass=*)", []) { }
    end
  end
end
