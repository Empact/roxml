dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'happymapper')

file_contents = File.read(dir + '/../spec/fixtures/pita.xml')

# The document `pita.xml` contains both a default namespace and the 'georss'
# namespace (for the 'point' xml_reader).
module PITA
  class Base
    include ROXML
    xml_convention :camelcase
  end

  class Item < Base
    xml_reader :asin, :from => 'ASIN'
    xml_reader :detail_page_url
    xml_reader :manufacturer, :in => './'
    # this is the only xml_reader that exists in a different namespace, so it
    # must be explicitly specified
    xml_reader :point, :from => 'point', :namespace => 'georss'
  end

  class Items < Base
    xml_reader :total_results, :as => Integer
    xml_reader :total_pages, :as => Integer
    xml_reader :items, [Item]
  end
end

item = PITA::Items.parse(file_contents, :single => true)
item.items.each do |i|
  puts i.asin, i.detail_page_url, i.manufacturer, ''
end