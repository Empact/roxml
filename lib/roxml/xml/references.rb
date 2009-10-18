module ROXML
  class RequiredElementMissing < Exception # :nodoc:
  end
  
  #
  # Internal base class that represents an XML - Class binding.
  #
  class XMLRef # :nodoc:
    delegate :required?, :array?, :blocks, :accessor, :default, :wrapper, :to => :opts

    def initialize(opts, instance)
      @opts = opts
      @instance = instance
    end

    def to_xml(instance)
      val = instance.__send__(accessor)
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
      namespacify(name)
    end

    def value_in(xml)
      xml = XML::Node.from(xml)
      value = fetch_value(xml)
      value = default if value.nil?

      freeze(apply_blocks(value))
    end

  private
    attr_reader :opts

    def conventionize(what)
      convention ||= @instance.class.respond_to?(:roxml_naming_convention) && @instance.class.roxml_naming_convention
      if !what.blank? && convention.respond_to?(:call)
        URI.unescape(convention.call(URI.escape(what, /\/|::/)))
      else
        what
      end
    end

    def namespacify(what)
      return "#{opts.namespace}:#{what}" if opts.namespace

      namespace = @instance.class.roxml_namespace || @default_namespace
      if namespace && what.present? && !what.include?(':') && (opts.namespace != false)
        "#{namespace}:#{what}"
      else
        what
      end
    end

    def apply_blocks(val)
      begin
        blocks.inject(val) {|val, block| block.call(val) }
      rescue Exception => ex
        raise ex, "#{accessor}: #{ex.message}"
      end
    end

    def freeze(val)
      if opts.frozen?
        val.each(&:freeze) if val.is_a?(Enumerable)
        val.freeze
      else
        val
      end
    end

    def xpath
      opts.wrapper ? "#{namespacify(opts.wrapper)}/#{xpath_name}" : xpath_name.to_s
    end

    def auto_xpath
      "#{namespacify(conventionize(opts.name.pluralize))}/#{xpath_name}" if array?
    end

    def several?
      array?
    end

    def wrap(xml)
      return xml if !wrapper || xml.name == wrapper
      if child = xml.children.find {|c| c.name == wrapper }
       return child
      end
      xml.add_child(XML::Node.create(wrapper.to_s))
    end

    def nodes_in(xml)
      @default_namespace = xml.default_namespace
      vals = xml.search(xpath, @instance.class.roxml_namespaces)

      if several? && vals.empty? && !wrapper && auto_xpath
        vals = xml.search(auto_xpath, @instance.class.roxml_namespaces)
        @auto_vals = !vals.empty?
      end

      if vals.empty?
        raise RequiredElementMissing, "#{name} from #{xml} for #{accessor}" if required?
        default
      elsif several?
        vals.map do |val|
          yield val
        end
      else
        yield(vals.first)
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
      xml.attributes[name] = value.to_s
    end

    def fetch_value(xml)
      nodes_in(xml) do |node|
        node.value
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
          add(xml.add_child(XML::Node.create(xpath_name)), v)
        end
      else
        add(xml.add_child(XML::Node.create(xpath_name)), value)
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
        nodes_in(xml) do |node|
          node.content.strip
        end
      end
    end

    def add(dest, value)
      if cdata?
        dest.add_child(XML::Node.new_cdata(value.to_s))
      else
        dest.content = value.to_s
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

    def several?
      true
    end

  private
    # Updates the composed XML object in the given XML block to
    # the value provided.
    def write_xml(xml, value)
      value.each_pair do |k, v|
        node = xml.add_child(XML::Node.create(hash.wrapper))
        @key.update_xml(node, k)
        @value.update_xml(node, v)
      end
    end

    def fetch_value(xml)
      nodes_in(xml) do |node|
        [@key.value_in(node), @value.value_in(node)]
      end
    end

    def apply_blocks(vals)
      unless blocks.empty?
        vals.collect! do |kvp|
          super(kvp)
        end
      end
      to_hash(vals) if vals
    end

    def freeze(vals)
      if opts.frozen?
        vals.each_pair{|k, v| k.freeze; v.freeze }
        vals.freeze
      else
        vals
      end
    end

    def to_hash(array)
      hash = array.inject({}) do |result, (k, v)|
        result[k] ||= []
        result[k] << v
        result
      end
      hash.each_pair do |k, v|
        hash[k] = v.first if v.size == 1
      end
    end
  end

  class XMLObjectRef < XMLTextRef # :nodoc:
    delegate :type, :to => :opts

  private
    # Updates the composed XML object in the given XML block to
    # the value provided.
    def write_xml(xml, value)
      params = {:name => name, :namespace => opts.namespace}
      if array?
        value.each do |v|
          xml.add_child(v.to_xml(params))
        end
      elsif value.is_a?(ROXML)
        xml.add_child(value.to_xml(params))
      else
        node = XML::Node.create(xpath_name)
        node.content = value.to_xml
        xml.add_child(node)
      end
    end

    def fetch_value(xml)
      nodes_in(xml) do |node|
        if type.respond_to? :from_xml
          type.from_xml(node)
        else
          type.new(node)
        end
      end
    end
  end
end