require 'rubygems'
require 'active_support/core_ext/symbol'
require 'active_support/core_ext/blank'
require 'active_support/core_ext/duplicable'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/object/misc' # returning
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/string/starts_ends_with'

require 'extensions/enumerable'
require 'extensions/array'

class Module
  include ActiveSupport::CoreExtensions::Module if ActiveSupport::CoreExtensions.const_defined? :Module
end

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