module ROXML
  HASH_KEYS = [:attrs, :key, :value].freeze

  class HashDefinition # :nodoc:
    attr_reader :key, :value
    attr_accessor :wrapper

    def initialize(opts)
      unless (invalid_keys = opts.keys - HASH_KEYS).empty?
        raise ArgumentError, "Invalid Hash description keys: #{invalid_keys.join(', ')}"
      end

      if opts.has_key? :attrs
        @key   = to_hash_args(opts, :from => "@#{opts[:attrs][0]}")
        @value = to_hash_args(opts, :from => "@#{opts[:attrs][1]}")
      else
        @key = to_hash_args opts, fetch_element(opts, :key)
        @value = to_hash_args opts, fetch_element(opts, :value)
      end
    end

  private
    def fetch_element(opts, what)
      case opts[what]
      when Hash
        raise ArgumentError, "Hash #{what} is over-specified: #{opts[what].inspect}" unless opts[what].keys.one?
        type = opts[what].keys.first
        {:from => opts[what][type], :as => type}
      when :content
        {:from => '.'}
      when :name
        {:from => '*'}
      when String, Symbol
        {:from => opts[what]}
      else
        raise ArgumentError, "unrecognized hash parameter: #{what} => #{opts[what]}"
      end
    end

    def to_hash_args(args, opts)
      args = [args] unless args.is_a? Array

      if args.one? && !(args.first.keys & HASH_KEYS).empty?
        Definition.new(opts[:from], opts)
      else
        opts = args.extract_options!
        raise opts.inspect
      end
    end
  end
end