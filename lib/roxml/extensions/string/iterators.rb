module ROXML
  module CoreExtensions
    module String #:nodoc:all
      module Iterators
        # Allows you to iterate over and modify the sub-strings between _separator_.  Returns the joined result of the modification.
        def between(separator, &block)
          split(separator).collect(&block).join(separator)
        end
      end
    end
  end
end