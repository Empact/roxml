module ROXML
  module CoreExtensions
    module Array #:nodoc:all
      module Conversions
        # Translates an array into a hash, where each element of the array is
        # an array with 2 elements:
        #
        #   >> [[:key, :value], [1, 2], ['key', 'value']].to_h
        #   => {:key => :value, 1 => 2, 'key' => 'value'}
        #
        def to_hash
          hash = inject({}) do |result, (k, v)|
            result[k] ||= []
            result[k] << v
            result
          end
          hash.each_pair do |k, v|
            hash[k] = v.first if v.one?
          end
          hash
        end

        def to_h #:nodoc:
          to_hash
        end
        deprecate :to_h => :to_hash

        def apply_to(val)
          # Only makes sense for arrays of blocks... maybe better outside Array...
          inject(val) {|val, block| block.call(val) }
        end
      end
    end
  end
end
