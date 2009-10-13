module ROXML
  unless const_defined? 'XML_PARSER'
    preferred_parsers = %w[nokogiri libxml]
    parser = preferred_parsers.shift
    begin
      require parser
      XML_PARSER = parser # :nodoc:
    rescue LoadError
      if preferred_parsers.present?
        parser = preferred_parsers.shift
        retry
      else
        warn <<-WARNING
ROXML is unable to locate libxml on your system, and so is falling back to
the much slower REXML.  It's best to check this out and get libxml working if possible.
WARNING
        XML_PARSER = 'rexml' # :nodoc:
      end
    end
  end

  require File.join('lib/roxml/xml/parsers', XML_PARSER)

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

require 'lib/roxml/xml/references'
