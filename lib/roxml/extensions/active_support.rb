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

class Object #:nodoc:
  unless method_defined?(:try)
    # Taken from the upcoming ActiveSupport 2.3
    #
    # Tries to send the method only if object responds to it. Return +nil+ otherwise.
    # It will also forward any arguments and/or block like Object#send does.
    #
    # ==== Example :
    #
    # # Without try
    # @person ? @person.name : nil
    #
    # With try
    # @person.try(:name)
    #
    # # try also accepts arguments/blocks for the method it is trying
    # Person.try(:find, 1)
    # @people.try(:map) {|p| p.name}
    def try(method, *args, &block)
      send(method, *args, &block) if respond_to?(method, true)
    end
  end
end