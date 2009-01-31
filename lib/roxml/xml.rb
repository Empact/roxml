module ROXML
  unless const_defined? 'XML_PARSER'
    begin
      require 'libxml'
      XML_PARSER = 'libxml' # :nodoc:
    rescue LoadError
      XML_PARSER = 'rexml' # :nodoc:
    end
  end

  require File.join(File.dirname(__FILE__), 'xml/parsers', XML_PARSER)

  module XML
    class Node
      def self.from(data)
        if data.is_a?(XML::Node)
          data
        elsif data.is_a?(File) || data.is_a?(IO)
          Parser.parse_io(data).root
        elsif (defined?(URI) && data.is_a?(URI::Generic)) ||
              (defined?(Pathname) && data.is_a?(Pathname))
          Parser.parse_file(data.to_s).root
        else
          Parser.parse(data).root
        end
      end
    end
  end
end

require File.join(File.dirname(__FILE__), 'xml/references')