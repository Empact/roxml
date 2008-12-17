module ROXML
  unless const_defined? 'XML_PARSER'
    begin
      require 'libxml'
      XML_PARSER = 'libxml' # :nodoc:
    rescue LoadError
      XML_PARSER = 'rexml' # :nodoc:
    end
  end
  require File.join(File.dirname(__FILE__), 'xml', XML_PARSER)

  class RequiredElementMissing < Exception # :nodoc:
  end

  #
  # Internal base class that represents an XML - Class binding.
  #
  class XMLRef # :nodoc:
    delegate :required?, :array?, :blocks, :accessor, :variable_name, :default, :to => :opts

    def initialize(opts, instance)
      @opts = opts
      @instance = instance
      @auto_wrapper = false
    end

    def to_xml
      val = @instance.__send__(accessor)
      opts.to_xml.respond_to?(:call) ? opts.to_xml.call(val) : val
    end

    def update_xml(xml, value)
      returning wrap(xml) do |xml|
        write_xml(xml, value)
      end
    end

    def name
      conventionize(opts.name)
    end
    alias_method :xpath_name, :name

    def default
      @default ||= @opts.default || (@opts.array? ? Array.new : nil)
      @default.duplicable? ? @default.dup : @default
    end

    def value_in(xml)
      value = fetch_value(xml)
      if value.blank?
        raise RequiredElementMissing, "#{name} from #{xml} for #{accessor}" if required?
        value = default
      end
      apply_blocks(value)
    end

  private
    attr_reader :opts

    def conventionize(what)
      if what.present? && @instance.try(:class).try(:roxml_naming_convention).respond_to?(:call)
         @instance.class.roxml_naming_convention.call(what)
      else
        what
      end
    end

    def wrapper
      conventionize(opts.wrapper)
    end

    def apply_blocks(val)
      blocks.apply_to(val)
    end

    def xpath
      wrapper ? "#{wrapper}/#{xpath_name}" : xpath_name.to_s
    end

    def auto_xpath
      "#{conventionize(opts.name.pluralize)}/#{xpath_name}" if array?
    end

    def wrap(xml)
      (wrapper && xml.name != wrapper) ? xml.child_add(XML::Node.new_element(wrapper)) : xml
    end

    def values(xml)
      raise "Only enumerable refs (Hash, Array) can have auto-wrappers" unless opts.hash? || opts.array?
      vals = xml.search(xpath)

      if vals.empty? && !wrapper && auto_xpath
        vals = xml.search(auto_xpath)
        @auto_vals = true unless vals.empty?
      end
      vals
    end
  end

  # Interal class representing an XML attribute binding
  #
  # In context:
  #  <element attribute="XMLAttributeRef">
  #   XMLTextRef
  #  </element>
  class XMLAttributeRef < XMLRef # :nodoc:
  private
    # Updates the attribute in the given XML block to
    # the value provided.
    def write_xml(xml, value)
      xml.attributes[name] = value.to_s.to_utf
    end

    def fetch_value(xml)
      attr = xml.search(xpath).first
      attr && attr.value
    end

    def xpath_name
      "@#{name}"
    end
  end

  # Interal class representing XML content text binding
  #
  # In context:
  #  <element attribute="XMLAttributeRef">
  #   XMLTextRef
  #  </element>
  class XMLTextRef < XMLRef # :nodoc:
    delegate :cdata?, :content?, :name?, :to => :opts

  private
    # Updates the text in the given _xml_ block to
    # the _value_ provided.
    def write_xml(xml, value)
      if content?
        add(xml, value)
      elsif name?
        xml.name = value
      elsif array?
        value.each do |v|
          add(xml.child_add(XML::Node.new_element(name)), v)
        end
      else
        add(xml.child_add(XML::Node.new_element(name)), value)
      end
    end

    def fetch_value(xml)
      if content?
        xml.content.strip
      elsif name?
        xml.name
      elsif array?
        values(xml).collect do |e|
          e.content.strip.to_latin if e.content
        end
      else
        child = xml.search(xpath).first
        child.content if child
      end
    end

    def add(dest, value)
      if cdata?
        dest.child_add(XML::Node.new_cdata(value.to_s.to_utf))
      else
        dest.content = value.to_s.to_utf
      end
    end
  end

  class XMLHashRef < XMLTextRef # :nodoc:
    delegate :hash, :to => :opts

    def initialize(opts, inst)
      super(opts, inst)
      @key = opts.hash.key.to_ref(inst)
      @value = opts.hash.value.to_ref(inst)
    end

  private
    # Updates the composed XML object in the given XML block to
    # the value provided.
    def write_xml(xml, value)
      value.each_pair do |k, v|
        node = xml.child_add(XML::Node.new_element(hash.wrapper))
        @key.update_xml(node, k)
        @value.update_xml(node, v)
      end
    end

    def fetch_value(xml)
      values(xml).collect do |e|
        [@key.value_in(e), @value.value_in(e)]
      end
    end

    def apply_blocks(vals)
      unless blocks.empty?
        vals.collect! do |kvp|
          super(kvp)
        end
      end
      vals.to_hash if vals
    end
  end

  class XMLObjectRef < XMLTextRef # :nodoc:
    delegate :type, :to => :opts

  private
    # Updates the composed XML object in the given XML block to
    # the value provided.
    def write_xml(xml, value)
      if array?
        value.each do |v|
          xml.child_add(v.to_xml(name))
        end
      elsif value.is_a?(ROXML)
        xml.child_add(value.to_xml(name))
      else
        node = XML::Node.new_element(name)
        node.content = value.to_xml
        xml.child_add(node)
      end
    end

    def fetch_value(xml)
      unless array?
        if child = xml.search(xpath).first
          instantiate(child)
        end
      else
        values(xml).collect do |e|
          instantiate(e)
        end
      end
    end

    def instantiate(elem)
      if type.respond_to? :from_xml
        type.from_xml(elem)
      else
        type.new(elem)
      end
    end
  end
end