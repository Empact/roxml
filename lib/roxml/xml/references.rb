module ROXML
  class RequiredElementMissing < Exception # :nodoc:
  end

  #
  # Internal base class that represents an XML - Class binding.
  #
  class XMLRef # :nodoc:
    attr_reader :opts
    delegate :required?, :array?, :accessor, :default, :wrapper, :to => :opts

    def initialize(opts, instance)
      @opts = opts
      @instance = instance
    end

    def blocks
      opts.blocks || []
    end

    def to_xml(instance)
      val = instance.__send__(accessor)
      opts.to_xml.respond_to?(:call) ? opts.to_xml.call(val) : val
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
    def conventionize(what)
      convention ||= @instance.class.respond_to?(:roxml_naming_convention) && @instance.class.roxml_naming_convention
      if !what.blank? && convention.respond_to?(:call)
        URI.unescape(convention.call(URI.escape(what, /\/|::/)))
      else
        what
      end
    end

    def namespacify(what)
      if what.to_s.present? && !what.to_s.include?(':') && opts.namespace != false
        [opts.namespace, @instance.class.roxml_namespace, @default_namespace].each do |namespace|
          return opts.namespace == '*' ? (what == '*' ? "*" : "*[local-name()='#{what}']") : "#{namespace}:#{what}" if namespace
        end
      end
      what
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

    def auto_wrapper
      namespacify(conventionize(opts.name.pluralize))
    end

    def auto_xpath
      "#{auto_wrapper}/#{xpath_name}" if array?
    end

    def several?
      array?
    end

    def wrap(xml, opts = {:always_create => false})
      wrap_with = @auto_vals ? auto_wrapper : wrapper

      return xml if !wrap_with || xml.name == wrap_with
      if !opts[:always_create] && (child = xml.children.find {|c| c.name == wrap_with })
       return child
      end
      XML.add_node(xml, wrap_with.to_s)
    end

    def nodes_in(xml)
      @default_namespace = xml.default_namespace
      vals = xml.roxml_search(xpath, @instance.class.roxml_namespaces)

      if several? && vals.empty? && !wrapper && auto_xpath
        vals = xml.roxml_search(auto_xpath, @instance.class.roxml_namespaces)
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
    # Updates the attribute in the given XML block to
    # the value provided.
    def update_xml(xml, values)
      if array?
        values.each do |value|
          wrap(xml, :always_create => true).tap do |node|
            XML.set_attribute(node, name, value.to_s)
          end
        end
      else
        wrap(xml).tap do |xml|
          XML.set_attribute(xml, name, values.to_s)
        end
      end
    end

  private
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

    # Updates the text in the given _xml_ block to
    # the _value_ provided.
    def update_xml(xml, value)
      wrap(xml).tap do |xml|
        if content?
          add(xml, value)
        elsif name?
          xml.name = value
        elsif array?
          value.each do |v|
            add(XML.add_node(xml, name), v)
          end
        else
          add(XML.add_node(xml, name), value)
        end
      end
    end

  private
    def fetch_value(xml)
      if content? || name?
        value =
          if content?
            xml.content.to_s
          elsif name?
            xml.name
          end

        if value.blank?
          raise RequiredElementMissing, "#{name} from #{xml} for #{accessor}" if required?
          default
        else
          value
        end
      else
        nodes_in(xml) do |node|
          node.content
        end
      end
    end

    def add(dest, value)
      if cdata?
        XML.add_cdata(dest, value.to_s)
      else
        XML.set_content(dest, value.to_s)
      end
    end
  end

  class XMLNameSpaceRef < XMLRef # :nodoc:
    private
      def fetch_value(xml)
        xml.namespace.prefix
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

    # Updates the composed XML object in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      wrap(xml).tap do |xml|
        value.each_pair do |k, v|
          node = XML.add_node(xml, hash.wrapper)
          @key.update_xml(node, k)
          @value.update_xml(node, v)
        end
      end
    end

  private
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
    delegate :sought_type, :to => :opts

    # Updates the composed XML object in the given XML block to
    # the value provided.
    def update_xml(xml, value)
      wrap(xml).tap do |xml|
        params = {:name => name, :namespace => opts.namespace}
        if array?
          value.each do |v|
            XML.add_child(xml, v.to_xml(params))
          end
        elsif value.is_a?(ROXML)
          XML.add_child(xml, value.to_xml(params))
        else
          XML.add_node(xml, name).tap do |node|
            XML.set_content(node, value.to_xml)
          end
        end
      end
    end

  private
    def fetch_value(xml)
      nodes_in(xml) do |node|
        if sought_type.respond_to? :from_xml
          sought_type.from_xml(node)
        else
          sought_type.new(node)
        end
      end
    end
  end
end
