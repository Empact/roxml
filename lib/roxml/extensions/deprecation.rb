require 'active_support'
require 'active_support/version'

module ActiveSupport # :nodoc:all
  if VERSION::MAJOR <= 2 && VERSION::MINOR <= 1
    module Deprecation
      class << self
        def deprecation_message(callstack, message = nil)
          message ||= "You are using deprecated behavior which will be removed from the next major or minor release."
          "DEPRECATION WARNING: #{message}. #{deprecation_caller_message(callstack)}"
        end
      end
    end
  end
end