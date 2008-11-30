require 'rubygems'
require 'active_support/core_ext/blank'
require 'active_support/core_ext/duplicable'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/misc' # returning
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/starts_ends_with'

require 'extensions/array'

class String #:nodoc:
  include ActiveSupport::CoreExtensions::String::Inflections
  include ActiveSupport::CoreExtensions::String::StartsEndsWith
end

class Array #:nodoc:
  include ActiveSupport::CoreExtensions::Array::ExtractOptions
end

class Hash #:nodoc:
  include ActiveSupport::CoreExtensions::Hash::ReverseMerge
end