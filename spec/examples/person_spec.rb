require 'spec_helper'
require_relative './../../examples/person'

describe Person do

  before do
    @person = Person.new
    @person.name = 'John Doe'
    @person.lat = '40.715224'
    @person.long = '-74.005966'
    @person.street = 'Evergreen Terrace'
    @person.city = 'Springfield'
    @person.zip = '2342'
  end

  it 'should only contain one location element' do
    expect(ROXML::XML.search(@person.to_xml, 'location').count).to eq(1)
  end

  describe '#to_xml' do
    before do
      @xml_generated = @person.to_xml.to_s.gsub("\n",'').squeeze(' ')
    end

    it 'should generate the expected xml' do
      xml_file = File.read(xml_for('person')).gsub("\n",'').squeeze(' ')
      expect(xml_file).to eq(@xml_generated)
    end

    it 'should generate identical xml after a full roundtrip' do
      p = Person.from_xml(@xml_generated)
      xml_roundtrip = p.to_xml.to_s.gsub("\n",'').squeeze(' ')
      expect(xml_roundtrip).to eq(@xml_generated)
    end
  end

end