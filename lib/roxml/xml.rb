module ROXML
  PARSERS = %w[nokogiri libxml].freeze
  unless const_defined? 'XML_PARSER'
    parsers = PARSERS.dup
    begin
      require parsers.first
      XML_PARSER = parsers.first # :nodoc:
    rescue LoadError
      parsers.shift
      retry unless parsers.empty?
      raise "Could not load a parser. Tried #{PARSERS.to_sentence}"
    end
  end

  require File.join('roxml/xml/parsers', XML_PARSER)

  module XML
    class Node
      def self.from(data)
        case data
        when XML::Node
          data
        when XML::Document
          data.root
        when File, IO
          XML.parse_io(data).root
        else
          if (defined?(URI) && data.is_a?(URI::Generic)) ||
             (defined?(Pathname) && data.is_a?(Pathname))
            XML.parse_file(data.to_s).root
          else
            XML.parse_string(data).root
          end
        end
      end
    end
  end
end

require 'roxml/xml/references'
