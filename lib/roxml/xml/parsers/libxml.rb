require 'libxml'
require 'cgi'

module ROXML
  module XML # :nodoc:all
    Document = LibXML::XML::Document
    Node = LibXML::XML::Node
    Parser = LibXML::XML::Parser
    Error = LibXML::XML::Error

    module NamespacedSearch
      def search(xpath, roxml_namespaces = {})
        if namespaces.default
          roxml_namespaces = {:xmlns => namespaces.default.href}.merge(roxml_namespaces)
        end
        if roxml_namespaces.present?
          find(xpath, roxml_namespaces.map {|prefix, href| [prefix, href].join(':') })
        else
          find(xpath)
        end
      end

    private
      def namespaced(xpath)
        xpath.split('/').map do |component|
          if component =~ /\w+/ && !component.include?(':') && !component.starts_with?('@')
            "xmlns:#{component}"
          else
            component
          end
        end.join('/')
      end
    end

    class Document
      include NamespacedSearch
      
      def default_namespace
        default = namespaces.default
        default.prefix || 'xmlns' if default
      end

    private
      delegate :namespaces, :to => :root
    end

    class Node
      include NamespacedSearch

      class << self
        def new_with_entity_escaping(name, content = nil, namespace = nil)
          new_without_entity_escaping(name, content && CGI.escapeHTML(content), namespace)
        end
        alias_method_chain :new, :entity_escaping

        alias :create :new
      end

      def default_namespace
        doc.default_namespace
      end

      def add_child(child)
        # libxml 1.1.3 changed child_add from returning child to returning self
        self << child
        child
      end

      alias_method :set_libxml_content, :content=
      def content=(string)
        set_libxml_content(string.gsub('&', '&amp;'))
      end
    end

    class Parser
      class << self
        def parse(str_data)
          string(str_data).parse
        end

        def parse_file(path)
          file(path).parse
        end

        def parse_io(stream)
          io(stream).parse
        end
      end
    end
  end
end