require File.join(File.dirname(__FILE__), 'hash_definition')

module ROXML
  class Definition # :nodoc:
    attr_reader :name, :type, :wrapper, :hash, :blocks, :accessor, :to_xml

    class << self
      def silence_xml_name_warning?
        @silence_xml_name_warning || (ROXML.const_defined?('SILENCE_XML_NAME_WARNING') && ROXML::SILENCE_XML_NAME_WARNING)
      end

      def silence_xml_name_warning!
        @silence_xml_name_warning = true
      end
    end

    def initialize(sym, *args, &block)
      @accessor = sym
      opts = extract_options!(args)
      opts[:as] << :bool if @accessor.to_s.ends_with?('?')
      @blocks = collect_blocks(block, opts[:as])

      if opts.has_key?(:readonly)
        raise ArgumentError, "There is no 'readonly' option. You probably mean to use :frozen => true"
      end

      @type = extract_type(args, opts)
      if @type.try(:xml_name_without_deprecation?)
        unless self.class.silence_xml_name_warning?
          warn "WARNING: As of 2.3, a breaking change has been in the naming of sub-objects. " +
               "ROXML now considers the xml_name of the sub-object before falling back to the accessor name of the parent. " +
               "Use :from on the parent declaration to override this behavior. Set ROXML::SILENCE_XML_NAME_WARNING to avoid this message."
          self.class.silence_xml_name_warning!
        end
        opts[:from] ||= @type.tag_name
      end

      opts[:from] = '.' if opts[:from] == :content

      @name = (opts[:from] || variable_name).to_s
      @name = @name.singularize if hash? || array?
      if hash? && (hash.key.name? || hash.value.name?)
        @name = '*'
      end

      raise ArgumentError, "Can't specify both :else default and :required" if required? && @default
    end

    def variable_name
      accessor.to_s.ends_with?('?') ? accessor.to_s.chomp('?') : accessor.to_s
    end

    def hash
      if hash?
        @type.wrapper ||= name
        @type
      end
    end

    def hash?
      @type.is_a?(HashDefinition)
    end

    def name?
      @name == '*'
    end

    def content?
      @name == '.'
    end

    def name_explicit?
      @name_explicit
    end

    def array?
      @array
    end

    def cdata?
      @cdata
    end

    def required?
      @required
    end

    def freeze?
      @frozen
    end

    def default
      if @default.nil?
        @default = [] if array?
        @default = {} if hash?
      end
      @default.duplicable? ? @default.dup : @default
    end

    def to_ref(inst)
      case type
      when :attr          then XMLAttributeRef
      when :text          then XMLTextRef
      when HashDefinition then XMLHashRef
      when Symbol         then raise ArgumentError, "Invalid type argument #{opts.type}"
      else                     XMLObjectRef
      end.new(self, inst)
    end

  private
    def self.all(items, &block)
      array = items.is_a?(Array)
      results = (array ? items : [items]).map do |item|
        yield item
      end

      array ? results : results.first
    end

    BLOCK_TO_FLOAT = lambda do |val|
      all(val) do |v|
        Float(v) unless blank_string?(v)
      end
    end

    BLOCK_TO_INT = lambda do |val|
      all(val) do |v|
        Integer(v) unless blank_string?(v)
      end
    end

    def self.fetch_bool(value, default)
      value = value.try(:downcase)
      if %w{true yes 1}.include? value
        true
      elsif %w{false no 0}.include? value
        false
      else
        default
      end
    end

    def self.blank_string?(value)
      value.is_a?(String) && value.blank?
    end

    BLOCK_SHORTHANDS = {
      :integer => BLOCK_TO_INT, # deprecated
      Integer  => BLOCK_TO_INT,
      :float   => BLOCK_TO_FLOAT, # deprecated
      Float    => BLOCK_TO_FLOAT,
      Date     => lambda do |val|
        if defined?(Date)
          all(val) {|v| Date.parse(v) unless blank_string?(v) }
        end
      end,
      DateTime => lambda do |val|
        if defined?(DateTime)
          all(val) {|v| DateTime.parse(v) unless blank_string?(v) }
        end
      end,
      Time     => lambda do |val|
        if defined?(Time)
          all(val) {|v| Time.parse(v) unless blank_string?(v) }
        end
      end,

      :bool    => nil,
      :bool_standalone => lambda do |val|
        all(val) do |v|
          fetch_bool(v, nil)
        end
      end,
      :bool_combined => lambda do |val|
        all(val) do |v|
          fetch_bool(v, v)
        end
      end
    }

    def collect_blocks(block, as)
      ActiveSupport::Deprecation.warn ":as => :float is deprecated.  Use :as => Float instead" if as.include?(:float)
      ActiveSupport::Deprecation.warn ":as => :integer is deprecated.  Use :as => Integer instead" if as.include?(:integer)

      shorthands = as & BLOCK_SHORTHANDS.keys
      if shorthands.size > 1
        raise ArgumentError, "multiple block shorthands supplied #{shorthands.map(&:to_s).join(', ')}"
      end

      shorthand = shorthands.first
      if shorthand == :bool
        # if a second block is present, and we can't coerce the xml value
        # to bool, we need to be able to pass it to the user-provided block
        shorthand = block ? :bool_combined : :bool_standalone
      end
      [BLOCK_SHORTHANDS[shorthand], block].compact
    end

    def extract_options!(args)
      opts = args.extract_options!
      unless (opts.keys & HASH_KEYS).empty?
        args.push(opts)
        opts = {}
      end
      opts.reverse_merge!(:as => [], :in => nil)
      @default = opts.delete(:else)
      @to_xml = opts.delete(:to_xml)
      @name_explicit = opts.has_key?(:from)
      @cdata = opts.delete(:cdata)
      @required = opts.delete(:required)
      @frozen = opts.delete(:frozen)
      @wrapper = opts.delete(:in)

      opts[:as] = [*opts[:as]]

      if opts[:as].include?(:cdata)
        @cdata = true
        ActiveSupport::Deprecation.warn ":as => :cdata is deprecated.  Please use :cdata => true"
      end

      if opts[:as].include?(:array)
        @array = true
        ActiveSupport::Deprecation.warn ":as => :array is deprecated.  Please use [] around your usual type declaration"
      end

      opts
    end

    def extract_type(args, opts)
      types = (opts.keys & TYPE_KEYS)
      # type arg
      if args.one? && types.empty?
        type = args.first
        if type.is_a? Array
          @array = true
          return type.first || :text
        elsif type.is_a? Hash
          return HashDefinition.new(type)
        elsif type == :content
          ActiveSupport::Deprecation.warn ":content as a type declaration is deprecated.  Use :from => '.' or :from => :content instead"
          opts[:from] = :content
          return :text
        else
          return type
        end
      end

      unless args.empty?
        raise ArgumentError, "too many arguments (#{(args + types).join(', ')}).  Should be name, type, and " +
                             "an options hash, with the type and options optional"
      end

      # type options
      if types.one?
        opts[:from] = opts.delete(types.first)
        if opts[:from] == :content
          opts[:from] = 'content'
          ActiveSupport::Deprecation.warn ":content is now a reserved as an alias for '.'. Use 'content' instead"
        end
        types.first
      elsif types.empty?
        :text
      else
        raise ArgumentError, "more than one type option specified: #{types.join(', ')}"
      end
    end
  end
end