require File.join(File.dirname(__FILE__), 'array/conversions')

class Array #:nodoc:
  include ROXML::CoreExtensions::Array::Conversions
end