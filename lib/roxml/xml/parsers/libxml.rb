require 'libxml'

module ROXML
  module XML # :nodoc:all
    Document = LibXML::XML::Document
    Node = LibXML::XML::Node
    Parser = LibXML::XML::Parser

    module NamespacedSearch
      def search(xpath)
        begin
          if default_namespace && !xpath.include?(':')
            find(namespaced(xpath),
                 in_default_namespace(default_namespace.href))
          else
            find(xpath)
          end
        rescue Exception => ex
          raise ex, xpath
        end
      end

    private
      def namespaced(xpath)
        xpath.between('/') do |component|
          if component =~ /\w+/ && !component.include?(':') && !component.starts_with?('@')
            in_default_namespace(component)
          else
            component
          end
        end
      end

      def in_default_namespace(name)
        "roxmldefaultnamespace:#{name}"
      end
    end

    class Document
      include NamespacedSearch

    private
      delegate :default_namespace, :to => :root
    end

    class Node
      include NamespacedSearch

    private
      def default_namespace
        @default_namespace ||= namespace && namespace.find {|n| n.to_s.nil? }
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