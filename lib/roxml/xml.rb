module ROXML
  module XML # ::nodoc::
    begin
      require 'libxml'
      Document = LibXML::XML::Document
      Node = LibXML::XML::Node
      class LibXML::XML::Node
        alias :search :find
        alias :search_first :find_first
      end
      Parser = LibXML::XML::Parser
      class LibXML::XML::Parser
        class << self
          def parse(str_data)
            string(str_data).parse
          end

          def parse_file(path)
            file(path).parse
          end
        end
      end
    rescue LoadError
      Node = REXML::Element
      class REXML::Element
        class << self
          def new_cdata(content)
            REXML::CData.new(content)
          end

          def new_element(name)
            name = name.id2name if name.is_a? Symbol
            REXML::Element.new(name)
          end
        end

        alias_attribute :content, :text

        def child_add(element)
          add_element(element)
        end

        def search(xpath)
          returning [] do |result|
            each_element(xpath) do |val|
              result << val
            end
          end
        end

        def search_first(xpath)
          elements[1, xpath]
        end
      end

      class Parser
        class << self
          def parse(string)
            REXML::Document.new(string)
          end

          def parse_file(path)
            REXML::Document.new(open(path), :ignore_whitespace_nodes => :all)
          end

          def register_error_handler(&block)
          end
        end
        ParseError = REXML::ParseException
      end
    end
  end

  #
  # Internal base class that represents an XML - Class binding.
  #
  class XMLRef # ::nodoc::
    attr_reader :accessor, :name, :array, :default, :block, :wrapper

    def initialize(accessor, args, &block)
      @accessor = accessor
      @array = args.array?
      @name = args.name
      @default = args.default
      @block = block
      @wrapper = args.wrapper
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
    def xpath
      wrapper ? "#{wrapper}#{xpath_separator}#{name}" : name.to_s
    end

    def wrap(xml)
      (wrapper && xml.name != wrapper) ? xml.child_add(XML::Node.new(wrapper)) : xml
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
      val = xml.attributes[name] || default
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
    attr_reader :cdata, :content

    def initialize(accessor, args, &block)
      super(accessor, args, &block)
      @content = args.content?
      @cdata = args.cdata?
    end

    # Updates the text in the given _xml_ block to
    # the _value_ provided.
    def update_xml(xml, value)
      parent = wrap(xml)
      if content
        add(parent, value)
      elsif name?
        parent.name = value
      elsif array
        value.each do |v|
          add(parent.child_add(XML::Node.new(name)), v)
        end
      else
        add(parent.child_add(XML::Node.new(name)), value)
      end
      xml
    end

    def value(xml)
      val = if content
        xml.content.strip
      elsif name?
        xml.name
      elsif array
        arr = xml.search(xpath).collect do |e|
          e.content.strip.to_latin if e.content
        end
        arr unless arr.empty?
      else
        child = xml.search_first(name)
        child.content if child
      end
      val = default unless val && !val.blank?
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
      if cdata
        dest.child_add(XML::Node.new_cdata(value.to_utf))
      else
        dest.content = value.to_utf
      end
    end
  end

  class XMLHashRef < XMLTextRef # ::nodoc::
    attr_reader :hash

    def initialize(accessor, args, &block)
      super(accessor, args, &block)
      @hash = args.hash
      if @hash.key.name? || @hash.value.name?
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
        [@hash.key.value(e), @hash.value.value(e)]
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
      xml.child_add(XML::Node.new(hash.wrapper))
    end
  end

  class XMLObjectRef < XMLTextRef # ::nodoc::
    attr_reader :klass

    def initialize(accessor, args, &block)
      super(accessor, args, &block)
      @klass = args.type
    end

    # Updates the composed XML object in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      parent = wrap(xml)
      unless array
        parent.child_add(value.to_xml(name))
      else
        value.each do |v|
          parent.child_add(v.to_xml(name))
        end
      end
      xml
    end

    def value(xml)
      val = unless array
        if child = xml.search_first(xpath)
          instantiate(child)
        end
      else
        arr = xml.search(xpath).collect do |e|
          instantiate(e)
        end
        arr unless arr.empty?
      end || default
      block ? block.call(val) : val
    end

  private
    def instantiate(elem)
      if klass.respond_to? :parse
        klass.parse(elem)
      else
        klass.new(elem)
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