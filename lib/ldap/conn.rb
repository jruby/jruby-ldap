module LDAP  
  module ConnImplementation
    def controls(*args)
      raise "NOT IMPLEMENTED"
    end

    def get_option(*args)
      raise "NOT IMPLEMENTED"
    end
    
    # Modify the RDN of the entry with DN, +dn+, giving it the new RDN,
    # +new_rdn+. If +delete_old_rdn+ is *true*, the old RDN value will be deleted
    # from the entry.
    def modrdn(dn, new_rdn, delete_old_rdn)
      begin 
        if delete_old_rdn
          @context.rename(dn, new_rdn)
        else
          obj = @context.lookup(dn)
          @context.bind(new_rdn, obj)
        end
        @err = 0
      rescue javax.naming.NameAlreadyBoundException => e
        @err = 68
      rescue javax.naming.InvalidNameException => e
        @err = 34
      rescue javax.naming.NoPermissionException => e
        @err = 50
      rescue javax.naming.directory.SchemaViolationException => e
        @err = 65
      rescue javax.naming.NamingException => e
        @err = 21
      rescue javax.naming.NoPermissionException => e
        @err = 50
      rescue javax.naming.NamingException => e
        @err = -1
      end
      raise LDAP::ResultError.wrap(LDAP::err2string(@err), e) if @err != 0
      self
    end

    def perror(*args)
      raise "NOT IMPLEMENTED"
    end

    def referrals(*args)
      raise "NOT IMPLEMENTED"
    end
    
    def result2error(*args)
      raise "NOT IMPLEMENTED"
    end

    def __jndi_context
      @context
    end
    
    def initialize(host='localhost', port=LDAP_PORT)
      @host = host
      @port = port
    end
    
    def err
      @err || 0
    end
    
    def err2string(err)
      LDAP.err2string(err)
    end

    def simple_bind(dn=nil, password=nil, &block)
      bind(dn, password, LDAP_AUTH_SIMPLE, &block)
    end

    def bind(dn=nil, password=nil, method=LDAP_AUTH_SIMPLE)
      raise LDAP::Error, "already bound" if bound?

      url = @use_ssl ? "ldaps://#@host:#@port/" : "ldap://#@host:#@port/"
      base_env = {javax.naming.Context::PROVIDER_URL => url}
      base_env[javax.naming.Context::SECURITY_PRINCIPAL] = dn if dn
      base_env[javax.naming.Context::SECURITY_CREDENTIALS] = password if password

      @current_env = java.util.Hashtable.new(LDAP::configuration(base_env))

      begin 
        @context = javax.naming.directory.InitialDirContext.new(@current_env)
        @err = 0
      rescue javax.naming.NoPermissionException => e
        @err = 50
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.NamingException => e
        @err = -1
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      end
      
      if !block_given?
        return self
      end

      begin 
        yield self

        return nil
      ensure
        unbind
      end
    end
    
    def set_option(opt, value)
      @err = 0
    end
    
    def add(dn, attrs)
      raise LDAP::InvalidDataError, "The LDAP handler has already unbound." unless bound?

      attrs = LDAP::hash2mods(LDAP::LDAP_MOD_ADD, attrs) if attrs.is_a?(Hash)

      begin 
        @context.create_subcontext(dn, LDAP::Mod.to_java_attributes(*attrs))
        @err = 0
      rescue javax.naming.NameNotFoundException => e
        @err = 32
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.InvalidNameException => e
        @err = 34
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.NoPermissionException => e
        @err = 50
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.directory.SchemaViolationException => e
        @err = 65
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.NamingException => e
        @err = 21
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      end
      self
    end

    def modify(dn, attrs)
      raise LDAP::InvalidDataError, "The LDAP handler has already unbound." unless bound?

      attrs = LDAP::hash2mods(LDAP::LDAP_MOD_REPLACE, attrs) if attrs.is_a?(Hash)

      begin 
        @context.modify_attributes(dn, LDAP::Mod.to_java_modification_items(*attrs))
        @err = 0
      rescue javax.naming.NameNotFoundException => e
        @err = 32
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.InvalidNameException => e
        @err = 34
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.NoPermissionException => e
        @err = 50
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.directory.SchemaViolationException => e
        @err = 65
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.NamingException => e
        @err = 21
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      end

      self
    end
    
    def delete(dn)
      raise LDAP::InvalidDataError, "The LDAP handler has already unbound." unless bound?

      begin
        @context.destroy_subcontext(dn)
        @err = 0
      rescue javax.naming.NameNotFoundException => e
        @err = 32
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.InvalidNameException => e
        @err = 34
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.NoPermissionException => e
        @err = 50
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.NamingException => e
        @err = 21
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      end
      self
    end
    
    def search(base_dn, scope, filter, attrs=nil, attrsonly=nil, sec=0, usec=0, s_attr=nil, s_proc=nil)
      raise LDAP::InvalidDataError, "The LDAP handler has already unbound." unless bound?

      controls = javax.naming.directory.SearchControls.new
      controls.search_scope = scope

      if attrs && !attrs.empty?
        controls.returning_attributes = attrs.to_java(:string)
      end
      if attrsonly
        controls.returning_obj_flag = true
      end

      if sec != 0 || usec != 0
        controls.time_limit = usec/1000 + sec*1000
      end

      begin 
        @context.search(base_dn, filter, controls).each do |val|
          yield LDAP::Entry.create_from_search_result(val)
        end

        @err = 0
      rescue javax.naming.NameNotFoundException => e
        @err = 32
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.InvalidNameException => e
        @err = 34
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      rescue javax.naming.NoPermissionException => e
        @err = 50
        raise LDAP::ResultError.wrap(LDAP::err2string(@err), e)
      end

      self
    end

    def search2(base_dn, scope, filter, attrs=nil, attrsonly=nil, sec=0, usec=0, s_attr=nil, s_proc=nil)
      arr = []
      search(base_dn, scope, filter, attrs, attrsonly, sec, usec, s_attr, s_proc) do |val|
        arr << LDAP::entry2hash(val)
      end
      arr
    end
    
    def unbind
      raise LDAP::InvalidDataError, "The LDAP handler has already unbound." unless bound?
      @context.close
      @err = 0
      @context = nil
    end
    
    def bound?
      !@context.nil?
    end
  end   
  

  class Conn
    class << self
      alias open new
    end

    def initialize(host='localhost', port=LDAP_PORT)
      super
      @use_ssl = false
    end
    
    include ConnImplementation
  end

  class SSLConn
    class << self
      alias open new
    end

    def initialize(host='localhost', port=LDAPS_PORT)
      super
      @use_ssl = true
    end
    
    include ConnImplementation
  end
end
