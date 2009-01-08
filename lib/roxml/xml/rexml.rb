require 'rexml/document'

module ROXML
  module XML # :nodoc:all
    Document = REXML::Document
    Node = REXML::Element

    class Node
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

      def search(xpath)
        REXML::XPath.match(self, xpath)
      end

      def child_add(element)
        if element.is_a?(REXML::CData)
          REXML::CData.new(element, true, self)
        else
          add_element(element)
        end
      end

      def ==(other)
        to_s == other.to_s
      end
    end

    class Parser
      class << self
        def parse(string)
          REXML::Document.new(string, :ignore_whitespace_nodes => :all)
        end

        def parse_file(path)
          parse(open(path))
        end

        def register_error_handler(&block)
        end
      end
      ParseError = REXML::ParseException
    end

    class Document
      delegate :search, :to => :root

      def root=(node)
        raise ArgumentError, "Root is already defined" if root
        add(node)
      end
    end
  end
end