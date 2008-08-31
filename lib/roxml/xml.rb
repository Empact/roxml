require 'libxml'

module ROXML
  module XML
    include LibXML::XML
  end

  #
  # Internal base class that represents an XML - Class binding.
  #
  class XMLRef
    attr_accessor :accessor, :name, :array

    def initialize(accessor, name = nil)
      @accessor = accessor
      @name = (name || accessor.id2name)
      @array = false
      yield self if block_given?
    end
  end

  # Interal class representing an XML attribute binding
  #
  # In context:
  #  <element attribute="XMLAttributeRef">
  #   XMLTextRef
  #  </element>
  class XMLAttributeRef < XMLRef
    # Updates the attribute in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      xml.attributes[name] = value.to_utf
      xml
    end

    # Reads data from the XML element and populates the object
    # instance accordingly.
    def populate(xml, instance)
      instance.instance_variable_set("@#{accessor}", xml.attributes[name])
      instance
    end
  end

  # Interal class representing XML content text binding
  #
  # In context:
  #  <element attribute="XMLAttributeRef">
  #   XMLTextRef
  #  </element>
  class XMLTextRef < XMLRef
    attr_accessor :cdata, :wrapper, :text_content

    # Updates the text in the given _xml_ block to
    # the _value_ provided.
    def update_xml(xml, value)
      parent = (wrapper ? xml.add_element(wrapper) : xml)
      if text_content
        parent.content = text(value)
      elsif array
        value.each do |v|
          parent.add_element(name).content = text(v)
        end
      else
        parent.add_element(name).content = text(value)
      end
      xml
    end

    # Reads data from the XML element and populates the text
    # accordingly.
    def populate(xml, instance)
      data = nil
      if text_content
        data = xml.content
      elsif array
        xpath = (wrapper ? "#{wrapper}/#{name}" : name.to_s)
        data = xml.find(xpath).collect do |e|
          e.text.strip.to_latin if e.text
        end
      else
        child = xml.find_first(name)
        data = child.content if child && child.content
      end
      instance.instance_variable_set("@#{accessor}", data) if data
      instance
    end

  private
    def text(value)
      cdata ? XML::Node.new_cdata(value.to_utf) : value.to_utf
    end
  end

  class XMLObjectRef < XMLTextRef
    attr_accessor :klass

    def initialize(accessor, name = nil, &block)
      super(accessor, name, &block)
      @name = klass.tag_name.to_s unless name
    end

    # Updates the composed XML object in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      parent = (wrapper ? xml.add_element(wrapper) : xml)
      unless array
        parent.add_element(value.to_xml)
      else
        value.each do |v|
          parent.add_element(v.to_xml)
        end
      end
      xml
    end

    # Reads data from the XML element and populates the references XML
    # object accordingly.
    def populate(xml, instance)
      data = nil
      unless array
        child = xml.find_first(name)
        if child
          data = klass.parse(child)
        end
      else
        xpath = (wrapper ? "#{wrapper}/#{name}" : name)
        data = xml.find(xpath).collect do |e|
          klass.parse(e)
        end
      end
      instance.instance_variable_set("@#{accessor}", data) if data
      instance
    end
  end

  #
  # Returns an XML::Node representing this object.
  #
  def to_xml
    returning XML::Node.new_element(tag_name) do |root|
      tag_refs.each do |ref|
        if v = __send__(ref.accessor)
          root = ref.update_xml(root, v)
        end
      end
    end
  end
end