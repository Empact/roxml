module ROXML
  unless const_defined? 'XML_PARSER'
    begin
      require 'libxml'
      XML_PARSER = 'libxml'
    rescue LoadError
      XML_PARSER = 'rexml'
    end
  end
  require File.join(File.dirname(__FILE__), 'xml', XML_PARSER)

  class RequiredElementMissing < Exception; end

  #
  # Internal base class that represents an XML - Class binding.
  #
  class XMLRef # ::nodoc::
    attr_reader :accessor, :block, :name
    delegate :required?, :array?, :default, :wrapper, :to => :opts

    def initialize(accessor, args, &block)
      if args.block && block
        # TODO: Curry blocks, until then, fail
        raise ArgumentError, "more than one block specification"
      end

      @accessor = accessor
      @name = args.name
      @block = args.block || block
      @opts = args
    end

    # Reads data from the XML element and populates the instance
    # accordingly.
    def populate(xml, instance)
      data = value(xml)
      instance.instance_variable_set("@#{accessor}", data) if data
      instance
    end

    def name?
      false
    end

  private
    attr_reader :opts

    def xpath
      wrapper ? "#{wrapper}#{xpath_separator}#{name}" : name.to_s
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
  class XMLAttributeRef < XMLRef # ::nodoc::
    # Updates the attribute in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      xml.attributes[name] = value.to_utf
      xml
    end

    def value(xml)
      parent = wrap(xml)
      unless val = xml.attributes[name]
        raise RequiredElementMissing if opts.required?
        val = default
      end
      block ? block.call(val) : val
    end

  private
    def xpath_separator
      '@'
    end
  end

  # Interal class representing XML content text binding
  #
  # In context:
  #  <element attribute="XMLAttributeRef">
  #   XMLTextRef
  #  </element>
  class XMLTextRef < XMLRef # ::nodoc::
    delegate :cdata?, :content?, :to => :opts

    # Updates the text in the given _xml_ block to
    # the _value_ provided.
    def update_xml(xml, value)
      parent = wrap(xml)
      if content?
        add(parent, value)
      elsif name?
        parent.name = value
      elsif array?
        value.each do |v|
          add(parent.child_add(XML::Node.new_element(name)), v)
        end
      else
        add(parent.child_add(XML::Node.new_element(name)), value)
      end
      xml
    end

    def value(xml)
      val = if content?
        xml.content.strip
      elsif name?
        xml.name
      elsif array?
        arr = xml.search(xpath).collect do |e|
          e.content.strip.to_latin if e.content
        end
        arr unless arr.empty?
      else
        child = xml.search(name).first
        child.content if child
      end
      if !val || val.blank?
        raise RequiredElementMissing if required?
        val = default
      end
      block ? block.call(val) : val
    end

    def name?
      name == '*'
    end

  private
    def xpath_separator
      '/'
    end

    def add(dest, value)
      if cdata?
        dest.child_add(XML::Node.new_cdata(value.to_utf))
      else
        dest.content = value.to_utf
      end
    end
  end

  class XMLHashRef < XMLTextRef # ::nodoc::
    delegate :hash, :to => :opts

    def initialize(accessor, args, &block)
      super(accessor, args, &block)
      if hash.key.name? || hash.value.name?
        @name = '*'
      end
    end

    # Updates the composed XML object in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      parent = wrap(xml)
      value.each_pair do |k, v|
        node = add_node(parent)
        hash.key.update_xml(node, k)
        hash.value.update_xml(node, v)
      end
      xml
    end

    def value(xml)
      vals = xml.search(xpath).collect do |e|
        [hash.key.value(e), hash.value.value(e)]
      end
      if vals.empty?
        raise RequiredElementMissing if required?
        vals = default
      end
      if block
        vals.collect! do |(key, val)|
          block.call(key, val)
        end
      end
      vals.to_h
    end

  private
    def add_node(xml)
      xml.child_add(XML::Node.new_element(hash.wrapper))
    end
  end

  class XMLObjectRef < XMLTextRef # ::nodoc::
    delegate :type, :to => :opts

    # Updates the composed XML object in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      parent = wrap(xml)
      unless array?
        parent.child_add(value.to_xml(name))
      else
        value.each do |v|
          parent.child_add(v.to_xml(name))
        end
      end
      xml
    end

    def value(xml)
      val = unless array?
        if child = xml.search(xpath).first
          instantiate(child)
        end
      else
        arr = xml.search(xpath).collect do |e|
          instantiate(e)
        end
        arr unless arr.empty?
      end
      unless val
        raise RequiredElementMissing if opts.required?
        val = default
      end
      block ? block.call(val) : val
    end

  private
    def instantiate(elem)
      if type.respond_to? :from_xml
        type.from_xml(elem)
      else
        type.new(elem)
      end
    end
  end

  #
  # Returns an XML::Node representing this object.
  #
  def to_xml(name = nil)
    returning XML::Node.new_element(name || tag_name) do |root|
      tag_refs.each do |ref|
        if v = __send__(ref.accessor)
          ref.update_xml(root, v)
        end
      end
    end
  end
end