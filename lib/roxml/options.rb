module ROXML
  HASH_KEYS = [:attrs, :key, :value].freeze
  TYPE_KEYS = [:attr, :text, :hash].freeze

  class HashDesc
    attr_reader :key, :value

    def initialize(opts)
      unless (invalid_keys = opts.keys - HASH_KEYS).empty?
        raise ArgumentError, "Invalid Hash description keys: #{invalid_keys.join(', ')}"
      end

      if opts.has_key? :attrs
        @key   = to_ref(opts, :attr, opts[:attrs][0])
        @value = to_ref(opts, :attr, opts[:attrs][1])
      else
        @key = to_ref opts, *fetch_element(opts, :key)
        @value = to_ref opts, *fetch_element(opts, :value)
      end
    end

    def types
      [@key.class, @value.class]
    end

    def names
      [@key.name, @value.name]
    end

  private
    def fetch_element(opts, what)
      case opts[what]
      when Hash
        raise ArgumentError, "Hash #{what} is over-specified: #{opts[what].pp_s}" unless opts[what].keys.one?
        type = opts[what].keys.first
        [type, opts[what][type]]
      when :text_content
        [:text_content, opts[:name]]
      when Symbol
        [:text, opts[what]]
      end
    end

    def to_ref(args, type, name)
      case type
      when :attr
        XMLAttributeRef.new(nil, to_hash_args(args, type, name))
      when :text
        XMLTextRef.new(nil, to_hash_args(args, type, name))
      when Symbol
        XMLTextRef.new(nil, to_hash_args(args, type, name))
      else
        raise ArgumentError, "Missing key description #{{:type => type, :name => name}.pp_s}"
      end
    end

    def to_hash_args(args, type, name)
      args = [args] unless args.is_a? Array

      if args.one? && !(args.only.keys & HASH_KEYS).empty?
        opts = {type => name}
        if type == :text_content
          opts[:type] = :text
          (opts[:as] ||= []) << :text_content
        end
        Opts.new(name, opts)
      else
        opts = args.extract_options!
        raise opts.to_s
      end
    end
  end

  class Opts
    attr_reader :type, :hash

    def initialize(sym, *args)
      @opts = extract_options!(args)

      @opts.reverse_merge!(:from => sym.to_s, :as => [], :else => nil, :in => nil)
      @opts[:as] = [*@opts[:as]]
      @type = extract_type(args)

      @name = @opts[:from].to_s
      @hash = HashDesc.new(@opts.delete(:hash)) if hash?
    end

    def name=(n)
      @name = n.to_s
    end

    def name
      enumerable? ? @name.singularize : @name
    end

    def default
      @opts[:else]
    end

    def enumerable?
      hash? || array?
    end

    def hash?
      @type == :hash
    end

    def array?
      @opts[:as].include? :array
    end

    def text_content?
      @opts[:as].include? :text_content
    end

    def cdata?
      @opts[:as].include? :cdata
    end

    def wrapper
      @opts[:in]
    end

  private
    def extract_options!(args)
      opts = args.extract_options!
      unless (opts.keys & HASH_KEYS).empty?
        args.push(opts)
        opts = {}
      end
      opts
    end

    def extract_type(args)
      types = (@opts.keys & TYPE_KEYS)
      # type arg
      if args.one? && types.empty?
        if args.only.is_a? Array
          @opts[:as] << :array
          return args.only.only
        elsif args.only.is_a? Hash
          @opts[:hash] = args.only
          return :hash
        else
          return args.only
        end
      end

      unless args.empty?
        raise ArgumentError, "too many arguments (#{(args + types).join(', ')}).  Should be name, type, and " +
                             "an options hash, with the type and options optional"
      end

      # type options
      if types.one?
        @opts[:from] = @opts.delete(types.only)
        types.only
      elsif types.empty?
        :text
      else
        raise ArgumentError, "more than one type option specified: #{types.join(', ')}"
      end
    end
  end
end