require 'java'

module LDAP
  def self.err2string(err)
    case err||0
    when -1 then "Can't contact LDAP server"
    when 0 then "Success"
    when 1 then "Operations error"
    when 2 then "Protocol error"
    when 3 then "Time limit exceeded"
    when 4 then "Size limit exceeded"
    when 5 then "Compare False"
    when 6 then "Compare True"
    when 7 then "Authentication method not supported"
    when 8 then "Strong(er) authentication required"
    when 9 then "Partial results and referral received"
    when 10 then "Referral"
    when 11 then "Administrative limit exceeded"
    when 12 then "Critical extension is unavailable"
    when 13 then "Confidentiality required"
    when 14 then "SASL bind in progress"
    when 15 then "Unknown error"
    when 16 then "No such attribute"
    when 17 then "Undefined attribute type"
    when 18 then "Inappropriate matching"
    when 19 then "Constraint violation"
    when 20 then "Type or value exists"
    when 21 then "Invalid syntax"
    when 32 then "No such object"
    when 33 then "Alias problem"
    when 34 then "Invalid DN syntax"
    when 35 then "Entry is a leaf"
    when 36 then "Alias dereferencing problem"
    when 47 then "Proxy Authorization Failure"
    when 48 then "Inappropriate authentication"
    when 49 then "Invalid credentials"
    when 50 then "Insufficient access"
    when 51 then "Server is busy"
    when 52 then "Server is unavailable"
    when 53 then "Server is unwilling to perform"
    when 54 then "Loop detected"
    when 64 then "Naming violation"
    when 65 then "Object class violation"
    when 66 then "Operation not allowed on non-leaf"
    when 67 then "Operation not allowed on RDN"
    when 68 then "Already exists"
    when 69 then "Cannot modify object class"
    when 70 then "Results too large"
    when 71 then "Operation affects multiple DSAs"
    when 80 then "Internal (implementation specific) error"
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
    @environment.merge attrs
  end
end

require 'ldap/constants'
require 'ldap/conn'
require 'ldap/entry'
require 'ldap/error'
require 'ldap/mod'

LDAP.load_configuration
