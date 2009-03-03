module ROXML
  module CoreExtensions
    module Array #:nodoc:all
      module Conversions
        def apply_to(val)
          # Only makes sense for arrays of blocks... maybe better outside Array...
          inject(val) {|val, block| block.call(val) }
        end
      end
    end
  end
end
