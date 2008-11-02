require File.join(File.dirname(__FILE__), 'string/conversions')
require File.join(File.dirname(__FILE__), 'string/iterators')

class String #:nodoc:
  include ROXML::CoreExtensions::String::Conversions
  include ROXML::CoreExtensions::String::Iterators
end

require File.join(File.dirname(__FILE__), 'deprecation')
class Object #:nodoc:
  # Deprecated in favor of explicit #to_s.to_utf
  def to_utf
    ActiveSupport::Deprecation.warn "This method will be removed from Object please use String#to_utf instead via explicit #to_s"
    to_s.to_utf
  end

  # Deprecated in favor of explicit #to_s.to_latin
  def to_latin
    ActiveSupport::Deprecation.warn "This method will be removed from Object please use String#to_latin instead via explicit #to_s"
    to_s.to_latin
  end
end