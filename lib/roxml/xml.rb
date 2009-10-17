module ROXML
  unless const_defined? 'XML_PARSER'
    PREFERRED_PARSERS = %w[nokogiri libxml].freeze
    parsers = PREFERRED_PARSERS.dup
    begin
      require parsers.first
      XML_PARSER = parsers.first # :nodoc:
    rescue LoadError
      if parsers.size > 1
        parsers.shift
        retry
      else
        raise "Could not load either nokogiri or libxml"
      end
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
          Parser.parse_io(data).root
        else
          if (defined?(URI) && data.is_a?(URI::Generic)) ||
             (defined?(Pathname) && data.is_a?(Pathname))
            Parser.parse_file(data.to_s).root
          else
            Parser.parse(data).root
          end
        end
      end
    end
  end
end

require 'roxml/xml/references'
