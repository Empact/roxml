module ROXML
  HASH_KEYS = [:attrs, :key, :value].freeze

  class HashDefinition # :nodoc:
    attr_reader :key, :value
    attr_accessor :wrapper

    def initialize(opts)
      unless (invalid_keys = opts.keys - HASH_KEYS).empty?
        raise ArgumentError, "Invalid Hash description keys: #{invalid_keys.join(', ')}"
      end

      if attrs = opts.delete(:attrs)
        opts = {
          :key => {:from => "@#{attrs[0]}"},
          :value => {:from => "@#{attrs[1]}"}
        }
      end
      @key = Definition.new(nil, fetch_element(opts, :key))
      @value = Definition.new(nil, fetch_element(opts, :value))
    end

  private
    def fetch_element(opts, what)
      case opts[what]
      when Hash
        opts[what]
      when String, Symbol
        {:from => opts[what]}
      else
        raise ArgumentError, "unrecognized hash parameter: #{what} => #{opts[what]}"
      end
    end
  end
end