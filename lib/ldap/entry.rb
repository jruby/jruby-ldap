
module LDAP
  class << self
    def entry2hash(entry)
      out = {}
      out['dn'] = [entry.dn]
      entry.get_attributes.each do |k|
        out[k] = entry[k]
      end
      out
    end
  end
  
  class Entry
    class << self
      def create_from_search_result(search_result)
        new(search_result.name_in_namespace, (search_result.attributes.get_all.inject({}){|hash, attr| 
                                                hash[attr.getID()] = attr.getAll.to_a; hash}))
      end
    end

    def initialize(dn, attributes)
      @dn = dn
      @attributes = attributes
      @keys = @attributes.keys
      @attributes = @keys.inject({}) do |hash, key|
        if @attributes[key].any?{|v| !v.is_a?(String)}
          @attributes[key] = @attributes[key].map do |val|
            val.is_a?(String) ? val : String.from_java_bytes(val)
          end
        end
        hash[key.downcase] = @attributes[key]
        hash
      end
    end
    
    def get_attributes
      @keys
    end

    alias attrs get_attributes

    def get_dn
      @dn
    end

    alias dn get_dn
    
    def get_values(attr)
      @attributes[attr.downcase]
    end
    
    alias vals get_values
    alias [] get_values
    
    def inspect
      super.split(' ').first + "\n#{(@keys.inject({}){|hash, name| hash[name] = @attributes[name.downcase];hash}.update('dn'=>[@dn])).inspect}>"
    end
    
    def hash
      @attributes.hash + @dn.hash
    end
  end
end
