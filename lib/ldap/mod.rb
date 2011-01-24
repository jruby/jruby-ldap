module LDAP
  class << self
    def mod(mod_type, attr, vals)
      Mod.new(mod_type, attr, vals)
    end

    def hash2mods(mod_type, hash)
      hash.map do |key, value|
        mod(mod_type, key, value)
      end
    end
  end

  class Mod
    BasicAttributes = javax.naming.directory.BasicAttributes
    BasicAttribute = javax.naming.directory.BasicAttribute
    ModificationItem = javax.naming.directory.ModificationItem
    DirContext = javax.naming.directory.DirContext
    class << self
      def to_java_attributes(*attrs)
        attrs.inject(BasicAttributes.new) do |res, attr|
          res.put(attr.to_java_attribute)
          res
        end
      end

      def ruby_mod_to_java(mod_op)
        case (mod_op&~LDAP::LDAP_MOD_BVALUES)
          when LDAP::LDAP_MOD_ADD then DirContext::ADD_ATTRIBUTE
          when LDAP::LDAP_MOD_REPLACE then DirContext::REPLACE_ATTRIBUTE
          when LDAP::LDAP_MOD_DELETE then DirContext::REMOVE_ATTRIBUTE
          else raise LDAP::Error, "can't handle operation #{mod_op}"
        end
      end
      
      def to_java_modification_items(*attrs)
        attrs.map do |val|
          ModificationItem.new(ruby_mod_to_java(val.mod_op), val.to_java_attribute)
        end.to_java ModificationItem
      end
    end
    
    def initialize(mod_type, attr, vals)
      @type, @attr, @vals = mod_type, attr, vals
    end

    def mod_op #should be mod_type
      @type
    end

    def mod_type #should be attr
      @attr
    end

    def mod_vals
      @vals
    end
    
    def to_java_attribute
      v = BasicAttribute.new(self.mod_type)
      binary = mod_op & LDAP::LDAP_MOD_BVALUES
      if binary != 0
        self.mod_vals.each do |val|
          v.add(val.to_java_bytes)
        end
      else
        self.mod_vals.each do |val|
          v.add(val)
        end
      end
      v
    end
  end
end
