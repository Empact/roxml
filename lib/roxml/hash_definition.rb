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
        ActiveSupport::Deprecation.warn(":as => {:attrs} is going away in 3.0.  Use explicit :key and :value instead.")
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
        if opts[what].keys.one?
          ActiveSupport::Deprecation.warn(":as => {:key => {Type => 'name'} ... } is going away in 3.0.  Use explicit :key => {:from => 'name', :as => Type} instead.")
          type = opts[what].keys.first
          case type
          when :attr
            {:from => "@#{opts[what][type]}"}
          when :text
            {:from => opts[what][type]}
          else
            {:as => type, :from => opts[what][type]}
          end
        else
          opts[what]
        end
      when String, Symbol
        {:from => opts[what]}
      else
        raise ArgumentError, "unrecognized hash parameter: #{what} => #{opts[what]}"
      end
    end

    def to_hash_args(args, opts)
      args = [args] unless args.is_a? Array

      if args.one? && !(args.first.keys & HASH_KEYS).empty?
        Definition.new(nil, opts)
      else
        opts = args.extract_options!
        raise opts.inspect
      end
    end
  end
end