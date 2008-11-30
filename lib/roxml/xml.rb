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
    delegate :name, :required?, :array?, :wrapper, :blocks, :accessor, :variable_name, :to => :opts
    alias_method :xpath_name, :name

    def initialize(opts)
      @opts = opts
    end

    # Reads data from the XML element and populates the instance
    # accordingly.
    def populate(xml, instance)
      data = value(xml)
      instance.instance_variable_set("@#{variable_name}", data)
      instance
    end

    def name?
      false
    end

    def update_xml(xml, value)
      returning wrap(xml) do |xml|
        write_xml(xml, value)
      end
    end

    def default
      @default ||= @opts.default || (@opts.array? ? Array.new : nil)
      @default.duplicable? ? @default.dup : @default
    end

    def value(xml)
      value = fetch_value(xml)
      if value.blank?
        raise RequiredElementMissing if required?
        value = default
      end
      apply_blocks(value)
    end

  private
    attr_reader :opts

    def apply_blocks(val)
      blocks.each {|block| val = block[*val] } unless blocks.empty?
      val
    end

    def xpath
      wrapper ? "#{wrapper}/#{xpath_name}" : xpath_name.to_s
    end

    def wrap(xml)
      (wrapper && xml.name != wrapper) ? xml.child_add(XML::Node.new_element(wrapper)) : xml
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
    delegate :cdata?, :content?, :to => :opts

    def name?
      name == '*'
    end

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
        xml.search(xpath).collect do |e|
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

    def default
      result = super
      result.nil? ? {} : result
    end

  private
    # Updates the composed XML object in the given XML block to
    # the value provided.
    def write_xml(xml, value)
      value.each_pair do |k, v|
        node = xml.child_add(XML::Node.new_element(hash.wrapper))
        hash.key.update_xml(node, k)
        hash.value.update_xml(node, v)
      end
    end

    def fetch_value(xml)
      xml.search(xpath).collect do |e|
        [hash.key.value(e), hash.value.value(e)]
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
      unless array?
        xml.child_add(value.to_xml(name))
      else
        value.each do |v|
          xml.child_add(v.to_xml(name))
        end
      end
    end

    def fetch_value(xml)
      unless array?
        if child = xml.search(xpath).first
          instantiate(child)
        end
      else
        xml.search(xpath).collect do |e|
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