#!/usr/bin/env ruby
require_relative './../spec/spec_helper'

class Person
	include ROXML
	
	xml_accessor :name, :from => 'name'

	xml_accessor :lat, :from => 'latitude',   :in => 'location/coordinates'
	xml_accessor :long, :from => 'longitude', :in => 'location/coordinates'

	xml_accessor :street, :from => 'street', :in => 'location/address'
	xml_accessor :city, :from => 'city', :in => 'location/address'
	xml_accessor :zip, :from => 'zip', :in => 'location/address'
end

unless defined?(RSpec) 
	p = Person.new
	p.name = 'John Doe'

	p.lat = '40.715224'
	p.long = '-74.005966'
	p.street = 'Evergreen Terrace'
	p.city = 'Springfield'
	p.zip = '2342'

	puts p.to_xml.to_s
end