require 'rexml/document'

module ROXML
  module XML # :nodoc:all
    Document = REXML::Document
    Node = REXML::Element

    module Error
      def self.reset_handler
        # noop
      end
    end
    [REXML::ParseException, REXML::UndefinedNamespaceException, REXML::Validation::ValidationException].each do |exception|
      exception.send(:include, Error)
    end

    class Node
      class << self
        def new_cdata(content)
          REXML::CData.new(content)
        end
      end

      alias_attribute :content, :text

      def search(xpath)
        begin
          REXML::XPath.match(self, xpath)
        rescue Exception => ex
          raise ex, xpath
        end
      end

      def add_child(element)
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
        def parse(source)
          REXML::Document.new(source, :ignore_whitespace_nodes => :all)
        end

        def parse_file(path) #:nodoc:
          path = path.sub('file:', '') if path.starts_with?('file:')
          parse(open(path))
        end

        def parse_io(path) #:nodoc:
          parse(path)
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

      def save(destination, opts = {:formatter => REXML::Formatters::Default.new})
        self << REXML::XMLDecl.new unless xml_decl != REXML::XMLDecl.default # always output xml declaration
        File.open(destination, "w") do |f|
          opts[:formatter].write(self, f)
        end
      end
    end
  end
end