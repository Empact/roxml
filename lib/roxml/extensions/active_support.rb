require 'rubygems'
require 'active_support/core_ext/symbol'
require 'active_support/core_ext/blank'
require 'active_support/core_ext/duplicable'
require 'active_support/core_ext/array/extract_options'

class Array #:nodoc:
  include ActiveSupport::CoreExtensions::Array::ExtractOptions
end

require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/object/misc' # returning
require 'active_support/inflector'
require 'active_support/multibyte'
require 'active_support/core_ext/string'
class String
  # This conflicts with builder, unless builder is required first, which we don't want to force on people
  undef_method :to_xs if method_defined?(:to_xs)
end

class Module #:nodoc:
  include ActiveSupport::CoreExtensions::Module if ActiveSupport::CoreExtensions.const_defined? :Module
end

class Hash #:nodoc:
  include ActiveSupport::CoreExtensions::Hash::ReverseMerge
end