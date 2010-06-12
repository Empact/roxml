require 'roxml/hash_definition'

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
  class ContradictoryNamespaces < StandardError
  end

  class Definition # :nodoc:
    attr_reader :name, :sought_type, :wrapper, :hash, :blocks, :accessor, :to_xml, :attr_name, :namespace
    bool_attr_reader :name_explicit, :array, :cdata, :required, :frozen

    def initialize(sym, opts = {}, &block)
      opts.assert_valid_keys(:from, :in, :as, :namespace,
                             :else, :required, :frozen, :cdata, :to_xml)
      @default = opts.delete(:else)
      @to_xml = opts.delete(:to_xml)
      @name_explicit = opts.has_key?(:from) && opts[:from].is_a?(String)
      @cdata = opts.delete(:cdata)
      @required = opts.delete(:required)
      @frozen = opts.delete(:frozen)
      @wrapper = opts.delete(:in)
      @namespace = opts.delete(:namespace)

      @accessor = sym.to_s
      opts[:as] ||=
        if @accessor.ends_with?('?')
          :bool
        elsif @accessor.ends_with?('_on')
          Date
        elsif @accessor.ends_with?('_at')
          DateTime
        end

      @array = opts[:as].is_a?(Array)
      @blocks = collect_blocks(block, opts[:as])

      @sought_type = extract_type(opts[:as])
      if @sought_type.respond_to?(:roxml_tag_name)
        opts[:from] ||= @sought_type.roxml_tag_name
      end

      if opts[:from] == :content
        opts[:from] = '.'
      elsif opts[:from] == :name
        opts[:from] = '*'
      elsif opts[:from] == :attr
        @sought_type = :attr
        opts[:from] = nil
      elsif opts[:from] == :namespace
        opts[:from] = '*'
        @sought_type = :namespace
      elsif opts[:from].to_s.starts_with?('@')
        @sought_type = :attr
        opts[:from].sub!('@', '')
      end

      @name = @attr_name = accessor.to_s.chomp('?')
      @name = @name.singularize if hash? || array?
      @name = (opts[:from] || @name).to_s
      if hash? && (hash.key.name? || hash.value.name?)
        @name = '*'
      end
      raise ContradictoryNamespaces if @name.include?(':') && (@namespace.present? || @namespace == false)

      raise ArgumentError, "Can't specify both :else default and :required" if required? && @default
    end

    def instance_variable_name
      :"@#{attr_name}"
    end

    def setter
      :"#{attr_name}="
    end

    def hash
      if hash?
        @sought_type.wrapper ||= name
        @sought_type
      end
    end

    def hash?
      @sought_type.is_a?(HashDefinition)
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
      case sought_type
      when :attr          then XMLAttributeRef
      when :text          then XMLTextRef
      when :namespace     then XMLNameSpaceRef
      when HashDefinition then XMLHashRef
      when Symbol         then raise ArgumentError, "Invalid type argument #{sought_type}"
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

    def self.fetch_bool(value, default)
      value = value.to_s.downcase
      if %w{true yes 1 t}.include? value
        true
      elsif %w{false no 0 f}.include? value
        false
      else
        default
      end
    end
    
    CORE_BLOCK_SHORTHANDS = {
      # Core Shorthands
      Integer  => lambda do |val|
        all(val) do |v|
          Integer(v) unless v.blank?
        end
      end,
      Float    => lambda do |val|
        all(val) do |v|
          Float(v) unless v.blank?
        end
      end,
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
      CORE_BLOCK_SHORTHANDS.tap do |blocks|
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
      if as.is_a?(Array)
        if as.size > 1
          raise ArgumentError, "multiple :as types (#{as.map(&:inspect).join(', ')}) is not supported.  Use a block if you want more complicated behavior."
        end

        as = as.first
      end

      if as == :bool
        # if a second block is present, and we can't coerce the xml value
        # to bool, we need to be able to pass it to the user-provided block
        as = (block ? :bool_combined : :bool_standalone)
      end
      as = self.class.block_shorthands.fetch(as) do
        unless (as == :text) || as.respond_to?(:from_xml) || (as.respond_to?(:first) && as.first.respond_to?(:from_xml)) || (as.is_a?(Hash) && !(as.keys & [:key, :value]).empty?)
          raise ArgumentError, "Invalid :as argument #{as}" unless as.nil?
        end
        nil
      end
      [as, block].compact
    end

    def extract_type(as)
      if as.is_a?(Hash)
        return HashDefinition.new(as)
      elsif as.respond_to?(:from_xml)
        return as
      elsif as.is_a?(Array) && as.first.respond_to?(:from_xml)
        @array = true
        return as.first
      else
        :text
      end
    end
  end
end
