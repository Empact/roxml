module Enumerable #:nodoc:all
  unless method_defined?(:one?)
    def one?
      size == 1
    end
  end
end

require File.join(File.dirname(__FILE__), 'array/conversions')

class Array #:nodoc:
  include ROXML::CoreExtensions::Array::Conversions
end