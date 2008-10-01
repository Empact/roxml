module ROXML
  module XML # ::nodoc::
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
      alias :search :get_elements

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
          REXML::Document.new(string)
        end

        def parse_file(path)
          REXML::Document.new(open(path), :ignore_whitespace_nodes => :all)
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