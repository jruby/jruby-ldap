module LDAP
  class Error < StandardError
    attr_accessor :java_exception
    def self.wrap(message, java_exception)
      p java_exception if $DEBUG
      exception = new(message)
      exception.java_exception = java_exception
      exception
    end
  end
  class ResultError < Error; end
  class InvalidDataError < Error; end
  class InvalidEntryError < InvalidDataError; end
end
