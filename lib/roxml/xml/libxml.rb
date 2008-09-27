require 'libxml'

module ROXML
  module XML # ::nodoc::
    Document = LibXML::XML::Document
    Node = LibXML::XML::Node
    Parser = LibXML::XML::Parser

    class Document
      alias :search :find
    end

    class Node
      alias :search :find
    end

    class Parser
      class << self
        def parse(str_data)
          string(str_data).parse
        end

        def parse_file(path)
          file(path).parse
        end
      end
    end
  end
end