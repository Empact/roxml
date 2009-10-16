require 'rubygems'
require 'pathname'
require 'test/support/fixtures'
require 'lib/roxml'

require 'spec/shared_specs' if defined?(Spec)

def xml_for(name)
  Pathname.new(File.dirname(__FILE__)).expand_path.dirname.join("examples/xml/#{name}.xml")
end

class RoxmlObject
  include ROXML
end
