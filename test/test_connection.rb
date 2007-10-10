require 'test/unit'
require 'setup'

class TestConnection < Test::Unit::TestCase
  def setup
    @conn = LDAP::Conn.new($LDAP_test_host, $LDAP_test_port)
    @conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    @conn.bind($LDAP_test_username, $LDAP_test_password)
  end
  
  def teardown
    @conn.unbind rescue nil
  end

  if defined?(JRUBY_VERSION)
  def test_rebind
    id = @conn.object_id

    assert_nothing_raised do
      @conn.unbind
      @conn.bind
    end

    id2 = @conn.object_id
    assert_equal( id, id2 )

    assert_nothing_raised do
      @conn.unbind
      @conn.simple_bind
    end

    id2 = @conn.object_id
    assert_equal( id, id2 )
  end
  end

  def test_double_bind
    assert_raises( LDAP::Error ) { @conn.bind }
    assert_raises( LDAP::Error ) { @conn.simple_bind }
  end

  def test_double_unbind
    assert_nothing_raised { @conn.unbind }
    assert_raises( LDAP::InvalidDataError ) { @conn.unbind }
  end

  def test_bound?
    assert( @conn.bound? )
    @conn.unbind
    assert( ! @conn.bound? )
  end
end
