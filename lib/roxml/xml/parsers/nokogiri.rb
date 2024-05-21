require 'nokogiri'

module ROXML
  module XML # :nodoc:all

    class << self
      def set_attribute(node, name, value)
        node[name] = value
      end

      def set_content(node, content)
        node.content = content
      end

      def new_node(name)
        Nokogiri::XML::Node.new(name, Document.new)
      end

      def add_node(parent, name)
        add_child(parent, Nokogiri::XML::Node.new(name, parent.document))
      end

      def add_cdata(parent, content)
        parent.add_child(Nokogiri::XML::CDATA.new(parent.document, content))
      end

      def add_child(parent, child)
        parent.add_child(child)
      end

      def parse_string(string)
        Nokogiri::XML(string)
      end

      def parse_file(path)
        path = path.sub('file:', '') if path.start_with?('file:')
        parse_io(open(path))
      end

      def parse_io(stream)
        Nokogiri::XML(stream)
      end

      def save_doc(doc, path)
        open(path, 'w') do |file|
          file << doc.serialize
        end
      end

      def default_namespace(doc)
        doc = doc.document if doc.respond_to?(:document)
        'xmlns' if doc.root.namespaces['xmlns']
      end

      def search(xml, xpath, roxml_namespaces = {})
        namespaces = roxml_namespaces
        namespaces = namespaces.merge(xml.root.namespaces) if xml.respond_to?(:root)
        namespaces.transform_keys! {|key| key.delete_prefix("xmlns:").delete_prefix("xmlns") }
        case xml
        when Nokogiri::XML::Document
          p xpath, namespaces
          xml.search(xpath, namespaces)
        else
          xpath = "./#{xpath}"
          (namespaces.any? ? xml.search(xpath, namespaces) : xml.search(xpath))
        end
      end
    end

    Document = Nokogiri::XML::Document
    Node = Nokogiri::XML::Node
  end
end
