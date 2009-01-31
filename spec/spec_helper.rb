require 'pathname'

DIR = Pathname.new(__FILE__).dirname
require DIR.join('../lib/roxml')

def example(name)
  DIR.join("../examples/#{name}.rb")
end

def xml_for(name)
  DIR.join("../examples/xml/#{name}.xml")
end