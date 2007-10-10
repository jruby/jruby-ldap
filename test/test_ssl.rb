require 'test/unit'
require 'setup'

class TestSSLAdd# < Test::Unit::TestCase
  def setup
    @conn = LDAP::SSLConn.new($LDAP_test_host, LDAP::LDAPS_PORT)
    @conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    @conn.bind($LDAP_test_username, $LDAP_test_password)
  end
  
  def teardown
    @conn.unbind rescue nil
  end

  def test_simple_add
    @conn.add("o=fox3,o=ruby_ldap_test_tree", {'o' => ["fox3"], 'objectClass' => ['organization']})
    assert_exists_in_ldap "o=fox3,o=ruby_ldap_test_tree", {'o' => ["fox3"]}
  ensure 
    @conn.delete("o=fox3,o=ruby_ldap_test_tree") rescue nil
  end
end
