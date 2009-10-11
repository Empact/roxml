require File.join(File.dirname(__FILE__), 'string/iterators')

class String #:nodoc:
  include ROXML::CoreExtensions::String::Iterators
end