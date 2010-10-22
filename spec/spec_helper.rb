require 'rubygems'
require 'pathname'
require_relative './../test/support/fixtures'
require_relative './../lib/roxml'
require_relative './shared_specs'

def xml_for(name)
  Pathname.new(File.dirname(__FILE__)).expand_path.dirname.join("examples/xml/#{name}.xml")
end

class RoxmlObject
  include ROXML
end
