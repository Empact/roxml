#!/usr/bin/env ruby
require_relative './../spec/spec_helper'

# The document `pita.xml` contains both a default namespace and the 'georss'
# namespace (for the 'point' xml_reader).
module PITA
  class Base
    include ROXML
    xml_convention :camelcase
  end

  class Item < Base
    xml_reader :asin, :from => 'ASIN'
    xml_reader :detail_page_url, :from => 'DetailPageURL'
    xml_reader :manufacturer, :in => 'ItemAttributes'
    # this is the only xml_reader that exists in a different namespace, so it
    # must be explicitly specified
    xml_reader :point, :namespace => 'georss'
  end

  class ItemSearchResponse < Base
    xml_reader :total_results, :as => Integer, :in => 'Items'
    xml_reader :total_pages, :as => Integer, :in => 'Items'
    xml_reader :items, :as => [Item]
  end
end

unless defined?(Spec)
  response = PITA::ItemSearchResponse.from_xml(xml_for('amazon'))
  p response.total_results
  p response.total_pages 
  response.items.each do |i|
    puts i.asin, i.detail_page_url, i.manufacturer, i.point, ''
  end
end