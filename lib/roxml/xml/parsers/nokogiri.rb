require 'nokogiri'

module ROXML
  module XML # :nodoc:all
    Document = Nokogiri::XML::Document
    Element = Nokogiri::XML::Element
    Node = Nokogiri::XML::Node

    module Error; end

    class Parser
      class << self
        def parse(string)
          Nokogiri::XML(string)
        end

        def parse_file(path) #:nodoc:
          path = path.sub('file:', '') if path.starts_with?('file:')
          parse(open(path))
        end

        def parse_io(stream) #:nodoc:
          parse(stream)
        end
      end
    end

    class Document
      def save(path)
        open(path, 'w') do |file|
          file << serialize
        end
      end

      def default_namespace
        'xmlns' if root.namespaces['xmlns']
      end
    end

    module NodeExtensions
      def search(xpath, roxml_namespaces = {})
        xpath = "./#{xpath}"
        (roxml_namespaces.present? ? super(xpath, roxml_namespaces) : super(xpath)).map {|i| i }
      end

      def attributes
        self
      end

      def default_namespace
        document.default_namespace
      end
    end

    class Element
      include NodeExtensions

      def empty?
        children.empty?
      end
    end

    class Node
      class << self
        def new_cdata(content)
          Nokogiri::XML::CDATA.new(Document.new, content)
        end

        def create(name)
          new(name, Document.new)
        end
      end
      include NodeExtensions
      alias :remove! :remove
    end
  end
end