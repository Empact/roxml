require 'libxml'

module ROXML
  module XML # :nodoc:all

    class << self
      def set_attribute(node, name, value)
        node.attributes[name] = value
      end

      def set_content(node, content)
        node.content = content.gsub('&', '&amp;')
      end

      def new_node(name)
        LibXML::XML::Node.new(name)
      end

      def add_node(parent, name)
        add_child(parent, new_node(name))
      end

      def add_cdata(parent, content)
        add_child(parent, LibXML::XML::Node.new_cdata(content))
      end

      def add_child(parent, child)
        parent << child
        child
      end

      def parse_string(str_data)
        LibXML::XML::Parser.string(str_data).parse
      end

      def parse_file(path)
        LibXML::XML::Parser.file(path).parse
      end

      def parse_io(stream)
        LibXML::XML::Parser.io(stream).parse
      end

      def save_doc(doc, path)
        doc.save(path)
      end

      def default_namespace(doc)
        doc = doc.doc if doc.respond_to?(:doc)
        default = doc.root.namespaces.default
        default.prefix || 'xmlns' if default
      end

      def search(xml, xpath, roxml_namespaces = {})
        if xml.namespaces.default
          roxml_namespaces = {:xmlns => namespaces.default.href}.merge(roxml_namespaces)
        end
        if roxml_namespaces.present?
          xml.find(xpath, roxml_namespaces.map {|prefix, href| [prefix, href].join(':') })
        else
          xml.find(xpath)
        end
      end
    end

    Document = LibXML::XML::Document
    Node = LibXML::XML::Node
  end
end
