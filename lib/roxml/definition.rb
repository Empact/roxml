require File.join(File.dirname(__FILE__), 'hash_definition')

class Module
  def bool_attr_reader(*attrs)
    attrs.each do |attr|
      define_method :"#{attr}?" do
        instance_variable_get(:"@#{attr}") || false
      end
    end
  end
end

module ROXML
  class Definition # :nodoc:
    attr_reader :name, :type, :wrapper, :hash, :blocks, :accessor, :to_xml
    bool_attr_reader :name_explicit, :array, :cdata, :required, :frozen

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
      if @accessor.to_s.ends_with?('_on')
        ActiveSupport::Deprecation.warn "In 3.0, attributes with names ending with _on will default to Date type, rather than :text"
      end
      if @accessor.to_s.ends_with?('_at')
        ActiveSupport::Deprecation.warn "In 3.0, attributes with names ending with _at will default to DateTime type, rather than :text"
      end

      opts = extract_options!(args)
      opts[:as] ||= :bool if @accessor.to_s.ends_with?('?')

      @array = opts[:as].is_a?(Array) || extract_from_as(opts, :array, "Please use [] around your usual type declaration")
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

      if opts[:from] == :content
        opts[:from] = '.' 
      elsif opts[:from] == :attr
        @type = :attr
        opts[:from] = nil
      elsif opts[:from].to_s.starts_with?('@')
        @type = :attr
        opts[:from].sub!('@', '')
      end

      @name = (opts[:from] || variable_name).to_s
      @name = @name.singularize if hash? || array?
      if hash? && (hash.key.name? || hash.value.name?)
        @name = '*'
      end

      raise ArgumentError, "Can't specify both :else default and :required" if required? && @default
    end

    def variable_name
      accessor.to_s.chomp('?')
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
      when Symbol         then raise ArgumentError, "Invalid type argument #{type}"
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
        Float(v) unless v.blank?
      end
    end

    BLOCK_TO_INT = lambda do |val|
      all(val) do |v|
        Integer(v) unless v.blank?
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
    
    CORE_BLOCK_SHORTHANDS = {
      # Core Shorthands
      :integer => BLOCK_TO_INT, # deprecated
      Integer  => BLOCK_TO_INT,
      :float   => BLOCK_TO_FLOAT, # deprecated
      Float    => BLOCK_TO_FLOAT,
      Fixnum   => lambda do |val|
        all(val) do |v|
          v.to_i unless v.blank?
        end
      end,
      Time     => lambda do |val|
        all(val) {|v| Time.parse(v) unless v.blank? }
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

    def self.block_shorthands
      # dynamically load these shorthands at class definition time, but
      # only if they're already availbable
      returning CORE_BLOCK_SHORTHANDS do |blocks|
        blocks.reverse_merge!(BigDecimal => lambda do |val|
          all(val) do |v|
            BigDecimal.new(v) unless v.blank?
          end
        end) if defined?(BigDecimal)

        blocks.reverse_merge!(DateTime => lambda do |val|
          if defined?(DateTime)
            all(val) {|v| DateTime.parse(v) unless v.blank? }
          end
        end) if defined?(DateTime)

        blocks.reverse_merge!(Date => lambda do |val|
          if defined?(Date)
            all(val) {|v| Date.parse(v) unless v.blank? }
          end
        end) if defined?(Date)
      end
    end

    def collect_blocks(block, as)
      ActiveSupport::Deprecation.warn ":as => :float is deprecated.  Use :as => Float instead" if as == :float
      ActiveSupport::Deprecation.warn ":as => :integer is deprecated.  Use :as => Integer instead" if as == :integer

      if as.is_a?(Array)
        unless as.one? || as.empty?
          raise ArgumentError, "multiple :as types (#{as.map(&:inspect).join(', ')}) is not supported.  Use a block if you want more complicated behavior."
        end

        as = as.first || :text
      end

      if as == :bool
        # if a second block is present, and we can't coerce the xml value
        # to bool, we need to be able to pass it to the user-provided block
        as = (block ? :bool_combined : :bool_standalone)
      end
      as = self.class.block_shorthands.fetch(as) do
        unless as.try(:include?, ROXML) || as.try(:first).try(:include?, ROXML)
          ActiveSupport::Deprecation.warn "#{as.inspect} is not a valid type declaration. ROXML will raise in this case in version 3.0" unless as.nil?
        end
        nil
      end
      [as, block].compact
    end

    def extract_options!(args)
      opts = args.extract_options!
      unless (opts.keys & HASH_KEYS).empty?
        args.push(opts)
        opts = {}
      end

      @default = opts.delete(:else)
      @to_xml = opts.delete(:to_xml)
      @name_explicit = opts.has_key?(:from)
      @cdata = opts.delete(:cdata)
      @required = opts.delete(:required)
      @frozen = opts.delete(:frozen)
      @wrapper = opts.delete(:in)

      @cdata ||= extract_from_as(opts, :cdata, "Please use :cdata => true")

      if opts[:as].is_a?(Array) && opts[:as].size > 1
        ActiveSupport::Deprecation.warn ":as should point to a single item. #{opts[:as].join(', ')} should be declared some other way."
      end

      opts
    end

    def extract_from_as(opts, entry, message)
      # remove with deprecateds...
      if [*opts[:as]].include?(entry)
        ActiveSupport::Deprecation.warn ":as => #{entry.inspect} is deprecated. #{message}"
        if opts[:as] == entry
          opts[:as] = nil
        else
          opts[:as].delete(entry)
        end
        true
      end
    end

    def extract_type(args, opts)
      types = (opts.keys & TYPE_KEYS)
      # type arg
      if args.one? && types.empty?
        type = args.first
        if type.is_a? Array
          ActiveSupport::Deprecation.warn "Array declarations should be passed as the :as parameter, for future release."
          @array = true
          return type.first || :text
        elsif type.is_a? Hash
          ActiveSupport::Deprecation.warn "Hash declarations should be passed as the :as parameter, for future release."
          return HashDefinition.new(type)
        elsif type == :content
          ActiveSupport::Deprecation.warn ":content as a type declaration is deprecated.  Use :from => '.' or :from => :content instead"
          opts[:from] = :content
          return :text
        elsif type == :attr
          ActiveSupport::Deprecation.warn ":attr as a type declaration is deprecated.  Use :from => '@attr_name' or :from => :attr instead"
          opts[:from].sub!('@', '') if opts[:from].to_s.starts_with?('@') # this is added back next line...
          opts[:from] = opts[:from].nil? ? :attr : "@#{opts[:from]}"
          return :attr
        else
          ActiveSupport::Deprecation.warn "Type declarations should be passed as the :as parameter, for future release."
          return type
        end
      end

      unless args.empty?
        raise ArgumentError, "too many arguments (#{(args + types).join(', ')}).  Should be name, type, and " +
                             "an options hash, with the type and options optional"
      end

      if opts[:as].is_a?(Hash)
        return HashDefinition.new(opts[:as])
      elsif opts[:as].try(:include?, ROXML)
        return opts[:as]
      elsif opts[:as].is_a?(Array) && opts[:as].first.try(:include?, ROXML)
        @array = true
        return opts[:as].first
      end

      # type options
      if types.one?
        opts[:from] = opts.delete(types.first)
        if opts[:from] == :content
          opts[:from] = 'content'
          ActiveSupport::Deprecation.warn ":content is now a reserved as an alias for '.'. Use the string 'content' instead"
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
