require 'spec_helper'
require_relative './../../examples/search_query'

describe SearchQuery do	

	before do
		@search = SearchQuery.new
		@search.query = 'This is a random search query.'

		@saved_search = SearchQuery.from_xml("<searchquery><query>Search for something</query></searchquery>")
	end

	it 'should return the default value for all attributes where no value is set' do
		expect(@search.language).to eq('EN')
		@search.max_results == 20
	end

	it 'should return the same object for the default value' do
		expect(@search.language.object_id).to eq(@search.language.object_id)
	end

	it 'should respect the defaults when loading from xml' do
		expect(@saved_search.language).to eq('EN')
		@saved_search.max_results == 20
	end
end
