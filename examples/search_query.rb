#!/usr/bin/env ruby
require_relative './../spec/spec_helper'

class SearchQuery  
	include ROXML
	xml_accessor :query
	xml_accessor :max_results, :else => 20, :as => Integer
	xml_accessor :language, :else => 'EN'
end


unless defined?(RSpec) 
	q = SearchQuery.new
	q.query = "Some random query string."
	puts q.to_xml.to_s
end

