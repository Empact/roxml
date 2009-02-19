module ROXML
  class HashDefinition # :nodoc:
    attr_reader :key, :value
    attr_accessor :wrapper

    def initialize(opts)
      opts.assert_valid_keys(:key, :value)

      @key = Definition.new(nil, to_definition_options(opts, :key))
      @value = Definition.new(nil, to_definition_options(opts, :value))
    end

  private
    def to_definition_options(opts, what)
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