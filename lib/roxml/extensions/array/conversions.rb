module ROXML
  module CoreExtensions
    module Array #:nodoc:
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
            hash[k] = v.only if v.one?
          end
          hash
        end

        def to_h #:nodoc:
          to_hash
        end
        deprecate :to_h => :to_hash
      end
    end
  end
end
