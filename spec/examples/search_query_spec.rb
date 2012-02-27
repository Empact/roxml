require 'spec_helper'
require_relative './../../examples/search_query'

describe SearchQuery do	

	before do
		@search = SearchQuery.new
		@search.query = 'This is a random search query.'

		@saved_search = SearchQuery.from_xml("<searchquery><query>Search for something</query></searchquery>")
	end

	it 'should return the default value for all attributes where no value is set' do
		@search.language.should == 'EN'
		@search.max_results == 20
	end

	it 'should respect the defaults when loading from xml' do
		@saved_search.language.should == 'EN'
		@saved_search.max_results == 20
	end
end