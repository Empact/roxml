require_relative './../spec_helper'
require_relative './../../examples/library_with_fines'

describe LibraryWithFines do

  let(:xml) { File.read(xml_for('library_with_fines')) }
  let(:library) { LibraryWithFines.from_xml(xml) }

  it "should read nested elements" do
    expect(library.fines).to be_a(Hash)
    library.fines.size == 3
    expect(library.fines).to have_key('talking')
    expect(library.fines['talking']).to match(/Stop asking/)
  end

  class String
    def remove_whitespace
      self.gsub(/\s{2,}/, '').gsub("\n", '')
    end
  end

  it "should write deeply nested elements" do
    xml_out = library.to_xml.to_s
    expect(xml_out.remove_whitespace).to eq(xml.remove_whitespace)
  end

  it "should write two children of library: name and policy" do
    expect(library.to_xml.children.map{|e| e.name }).to eq(['name', 'policy'])
  end

  it "should be re-parsable via .from_xml" do
    lib_reparsed = LibraryWithFines.from_xml(library.to_xml.to_s)
    expect(lib_reparsed.name).to eq(library.name)
    expect(lib_reparsed.fines).to eq(library.fines)
  end


end
