require 'rubygems'
require 'pathname'
require 'test/support/fixtures'

require 'spec/shared_specs' if defined?(Spec)

DIR = Pathname.new(__FILE__ + '../..').expand_path.dirname
require 'lib/roxml'

def xml_for(name)
  DIR.join("examples/xml/#{name}.xml")
end