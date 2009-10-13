require 'rubygems'
require 'pathname'
require 'test/support/fixtures'

DIR = Pathname.new(__FILE__ + '../..').expand_path.dirname
require 'lib/roxml'

if defined?(Spec)
  require 'spec/shared_specs'
end

def example(name)
  DIR.join("examples/#{name}.rb")
end

def xml_for(name)
  DIR.join("examples/xml/#{name}.xml")
end