module ROXML
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
      opts.name_explicit? ? opts.name : conventionize(opts.name)
    end

    def xpath_name
      if !opts.name_explicit? && namespace = @instance.class.roxml_namespace
        "#{namespace}:#{name}"
      else
        name
      end
    end

    def value_in(xml)
      value = fetch_value(xml)
      freeze(apply_blocks(value))
    end

  private
    attr_reader :opts

    def conventionize(what)
      if !what.blank? && @instance.try(:class).try(:roxml_naming_convention).respond_to?(:call)
        require 'uri'
        URI.unescape(@instance.class.roxml_naming_convention.call(URI.escape(what, /\/|::/)))
      else
        what
      end
    end

    def wrapper
      conventionize(opts.wrapper)
    end

    def apply_blocks(val)
      begin
        blocks.apply_to(val)
      rescue Exception => ex
        raise ex, "#{accessor}: #{ex.message}"
      end
    end

    def freeze(val)
      if opts.freeze?
        val.each(&:freeze) if val.is_a?(Enumerable)
        val.freeze
      else
        val
      end
    end

    def xpath
      wrapper ? "#{wrapper}/#{xpath_name}" : xpath_name.to_s
    end

    def auto_xpath
      "#{conventionize(opts.name.pluralize)}/#{xpath_name}" if array?
    end

    def wrap(xml)
      return xml if !wrapper || xml.name == wrapper
      if child = xml.children.find {|c| c.name == wrapper }
       return child
      end
      xml.child_add(XML::Node.new_element(wrapper))
    end

    def nodes_in(xml)
      vals = xml.search(xpath)

      if (opts.hash? || opts.array?) && vals.empty? && !wrapper && auto_xpath
        vals = xml.search(auto_xpath)
        @auto_vals = !vals.empty?
      end

      if vals.empty?
        raise RequiredElementMissing, "#{name} from #{xml} for #{accessor}" if required?
        default
      else
        yield(vals)
      end
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
      nodes_in(xml) do |nodes|
        nodes.first.value
      end
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
      if content? || name?
        value =
          if content?
            xml.content.to_s.strip
          elsif name?
            xml.name
          end

        if value.empty?
          raise RequiredElementMissing, "#{name} from #{xml} for #{accessor}" if required?
          default
        else
          value
        end
      else
        nodes_in(xml) do |nodes|
          if array?
            nodes.collect do |e|
              e.content.strip.to_latin
            end
          else
            nodes.first.content
          end
        end
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
      nodes_in(xml) do |nodes|
        nodes.collect do |e|
          [@key.value_in(e), @value.value_in(e)]
        end
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

    def freeze(vals)
      if opts.freeze?
        vals.each_pair{|k, v| k.freeze; v.freeze }
        vals.freeze
      else
        vals
      end
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
      nodes_in(xml) do |nodes|
        unless array?
          instantiate(nodes.first)
        else
          nodes.collect do |e|
            instantiate(e)
          end
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