require 'active_support/core_ext/kernel/reporting'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/deprecation'
require 'active_support/version'

module ActiveSupport # :nodoc:all
  module Deprecation
    class << self
      if VERSION::MAJOR <= 2 && VERSION::MINOR <= 1
        def deprecation_message(callstack, message = nil)
          message ||= "You are using deprecated behavior which will be removed from the next major or minor release."
          "DEPRECATION WARNING: #{message}. #{deprecation_caller_message(callstack)}"
        end
      end
    end

    module ClassMethods
      def deprecated_method_warning(method_name, message=nil)
        warning = "#{method_name} is deprecated and will be removed from the next major or minor release."
        case message
          when Symbol then "#{warning} (use #{message} instead)"
          when String then "#{warning} (#{message})"
          else warning
        end
      end
    end
  end
end