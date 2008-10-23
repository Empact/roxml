module ActiveSupport
  module Deprecation
    class << self
      def deprecation_message(callstack, message = nil)
        "DEPRECATION WARNING: #{message} #{deprecation_caller_message(callstack)}"
      end
    end
  end
end