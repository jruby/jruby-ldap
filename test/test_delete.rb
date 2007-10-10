require 'test/unit'
require 'setup'

class TestDelete < Test::Unit::TestCase
  def setup
    @conn = LDAP::Conn.new($LDAP_test_host, $LDAP_test_port)
    @conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    @conn.bind($LDAP_test_username, $LDAP_test_password)
  end
  
  def teardown
    @conn.unbind rescue nil
  end

  def test_simple_delete
    @conn.add("o=fox3,o=ruby_ldap_test_tree", {'o' => ["fox3"], 'objectClass' => ['organization']})
    assert_exists_in_ldap "o=fox3,o=ruby_ldap_test_tree"
    @conn.delete("o=fox3,o=ruby_ldap_test_tree")
    assert_dont_exists_in_ldap "o=fox3,o=ruby_ldap_test_tree"
  end
end
