module ROXML
  HASH_KEYS = [:attrs, :key, :value].freeze
  TYPE_KEYS = [:attr, :text, :hash, :content].freeze

  class HashDesc # :nodoc:
    attr_reader :key, :value, :wrapper

    def initialize(opts, wrapper)
      unless (invalid_keys = opts.keys - HASH_KEYS).empty?
        raise ArgumentError, "Invalid Hash description keys: #{invalid_keys.join(', ')}"
      end

      @wrapper = wrapper
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
        if type == :content
          opts[:type] = :text
          (opts[:as] ||= []) << :content
        end
        Opts.new(name, opts)
      else
        opts = args.extract_options!
        raise opts.to_s
      end
    end
  end

  class Opts # :nodoc:
    attr_reader :name, :type, :hash, :blocks

    def initialize(sym, *args, &block)
      @opts = extract_options!(args)

      @opts.reverse_merge!(:as => [], :else => nil, :in => nil)
      @opts[:as] = [*@opts[:as]]

      @type = extract_type(args)
      if @type.respond_to?(:xml_name?) && @type.xml_name?
        warn "WARNING: As of 2.3, a breaking change has been in the naming of sub-objects. " +
             "ROXML now considers the xml_name of the sub-object before falling back to the accessor name of the parent. " +
             "Use :from on the parent declaration to override this behavior. Set ROXML::SILENCE_XML_NAME_WARNING to remove this message." unless SILENCE_XML_NAME_WARNING
        @opts[:from] ||= @type.tag_name
      else
        @opts[:from] ||= sym.to_s
      end

      @blocks = collect_blocks(block, @opts[:as])

      @name = @opts[:from].to_s
      @name = @name.singularize if hash? || array?
      if hash? && (hash.key.name? || hash.value.name?)
        @name = '*'
      end

      raise ArgumentError, "Can't specify both :else default and :required" if required? && default
    end

    def hash
      @hash ||= HashDesc.new(@opts.delete(:hash), name) if hash?
    end

    def default
      @opts[:else]
    end

    def hash?
      @type == :hash
    end

    def content?
      @type == :content
    end

    def array?
      @opts[:as].include? :array
    end

    def cdata?
      @opts[:as].include? :cdata
    end

    def wrapper
      @opts[:in]
    end

    def required?
      @opts[:required]
    end

  private
    BLOCK_SHORTHANDS = {
      :integer => lambda {|val| Integer(val) },
      Integer  => lambda {|val| Integer(val) },
      :float   => lambda {|val| Float(val) },
      Float    => lambda {|val| Float(val) }
    }

    def collect_blocks(block, as)
      shorthands = as & BLOCK_SHORTHANDS.keys
      raise ArgumentError, "multiple block shorthands supplied #{shorthands.map(&:to_s).join(', ')}" if shorthands.size > 1
      [BLOCK_SHORTHANDS[shorthands.first], block].compact
    end

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