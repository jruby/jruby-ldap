require 'java'

module LDAP
  def self.err2string(err)
    case err||0
    when -1: "Can't contact LDAP server"
    when 0: "Success"
    when 1: "Operations error"
    when 2: "Protocol error"
    when 3: "Time limit exceeded"
    when 4: "Size limit exceeded"
    when 5: "Compare False"
    when 6: "Compare True"
    when 7: "Authentication method not supported"
    when 8: "Strong(er) authentication required"
    when 9: "Partial results and referral received"
    when 10: "Referral"
    when 11: "Administrative limit exceeded"
    when 12: "Critical extension is unavailable"
    when 13: "Confidentiality required"
    when 14: "SASL bind in progress"
    when 15: "Unknown error"
    when 16: "No such attribute"
    when 17: "Undefined attribute type"
    when 18: "Inappropriate matching"
    when 19: "Constraint violation"
    when 20: "Type or value exists"
    when 21: "Invalid syntax"
    when 32: "No such object"
    when 33: "Alias problem"
    when 34: "Invalid DN syntax"
    when 35: "Entry is a leaf"
    when 36: "Alias dereferencing problem"
    when 47: "Proxy Authorization Failure"
    when 48: "Inappropriate authentication"
    when 49: "Invalid credentials"
    when 50: "Insufficient access"
    when 51: "Server is busy"
    when 52: "Server is unavailable"
    when 53: "Server is unwilling to perform"
    when 54: "Loop detected"
    when 64: "Naming violation"
    when 65: "Object class violation"
    when 66: "Operation not allowed on non-leaf"
    when 67: "Operation not allowed on RDN"
    when 68: "Already exists"
    when 69: "Cannot modify object class"
    when 70: "Results too large"
    when 71: "Operation affects multiple DSAs"
    when 80: "Internal (implementation specific) error"
    else "Unknown error"
    end
  end

  def self.load_configuration(attrs={})
    env = nil
    env = javax.naming.directory.InitialDirContext.new.environment rescue nil
    default = {'java.naming.factory.initial' => 'com.sun.jndi.ldap.LdapCtxFactory'}
    if env
      env2 = default.dup
      env.each do |k,v|
        env2[k.to_s] = v.to_s
      end
      env = env2
    else
      env = default.dup
    end
    env.merge! attrs
    @environment = env
  end
  
  def self.configuration(attrs = { })
    @environment.update attrs
  end
end

require 'ldap/constants'
require 'ldap/conn'
require 'ldap/entry'
require 'ldap/error'
require 'ldap/mod'

LDAP.load_configuration
