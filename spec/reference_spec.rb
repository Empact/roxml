# encoding: utf-8
require_relative './spec_helper'

describe ROXML::XMLRef do

  class Org
    include ROXML
    xml_accessor :fines,
                 :in   => 'policy/fines',
                 :from => 'fine',
                 :as   => { :key => 'name', :value => 'desc' }
  end

  let(:org) do
    org = Org.new
    org.fines = { 'name' => 'a fine', 'desc' => 'a desc' }
    org
  end

  let(:reference) do
    Org.roxml_attrs.first.to_ref(org)
  end

  it "should properly reconstruct wrappers with multiple elements" do

    expect(reference).to be_a(ROXML::XMLHashRef)

    xml = ROXML::XML.new_node('org').tap do |root|
      reference.update_xml(root, org.fines)
    end

    expect(xml_path( xml )).to eq(%w{org policy fines fine name})
  end
end
