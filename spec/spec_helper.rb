require 'ostruct'
require 'rubygems'
require 'pathname'
require 'ostruct'
require 'rspec/matchers' # req by equivalent-xml custom matcher `be_equivalent_to`
require 'equivalent-xml'

require_relative './../test/support/fixtures'
require_relative './../lib/roxml'
require_relative './shared_specs'

def xml_for(name)
  Pathname.new(File.dirname(__FILE__)).expand_path.dirname.join("examples/xml/#{name}.xml")
end

class RoxmlObject
  include ROXML
end

# returns an array representing the path  through first child of each element in the doc
def xml_path(xml, path = [])
  path << xml.name if xml.is_a?(Nokogiri::XML::Element)
  unless xml.children.empty?
    xml_path(xml.children.first, path)
  end
  return path
end
