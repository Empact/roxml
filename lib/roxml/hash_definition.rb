module ROXML
  HASH_KEYS = [:attrs, :key, :value].freeze
  TYPE_KEYS = [:attr, :text, :hash, :content].freeze

  class HashDefinition # :nodoc:
    attr_reader :key, :value
    attr_accessor :wrapper

    def initialize(opts)
      unless (invalid_keys = opts.keys - HASH_KEYS).empty?
        raise ArgumentError, "Invalid Hash description keys: #{invalid_keys.join(', ')}"
      end

      if opts.has_key? :attrs
        @key   = to_hash_args(opts, :attr, opts[:attrs][0])
        @value = to_hash_args(opts, :attr, opts[:attrs][1])
      else
        @key = to_hash_args opts, *fetch_element(opts, :key)
        @value = to_hash_args opts, *fetch_element(opts, :value)
      end
    end

  private
    def fetch_element(opts, what)
      case opts[what]
      when Hash
        raise ArgumentError, "Hash #{what} is over-specified: #{opts[what].inspect}" unless opts[what].keys.one?
        type = opts[what].keys.first
        [type, opts[what][type]]
      when :content
        [:content, opts[:name]]
      when :name
        [:name, '*']
      when String
        [:text, opts[what]]
      when Symbol
        [:text, opts[what]]
      else
        raise ArgumentError, "unrecognized hash parameter: #{what} => #{opts[what]}"
      end
    end

    def to_hash_args(args, type, name)
      args = [args] unless args.is_a? Array

      if args.one? && !(args.first.keys & HASH_KEYS).empty?
        opts = {type => name}
        if type == :content
          opts[:type] = :text
          (opts[:as] ||= []) << :content
        end
        Definition.new(name, opts)
      else
        opts = args.extract_options!
        raise opts.inspect
      end
    end
  end
end