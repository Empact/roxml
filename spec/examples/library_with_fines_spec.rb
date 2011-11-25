require_relative './../spec_helper'
require_relative './../../examples/library_with_fines'

describe LibraryWithFines do

  let(:xml) { File.read(xml_for('library_with_fines')) }
  let(:library) { LibraryWithFines.from_xml(xml) }

  it "should read nested elements" do
    library.fines.should be_a(Hash)
    library.fines.size == 3
    library.fines.should have_key('talking')
    library.fines['talking'].should match(/Stop asking/)
  end

  class String
    def remove_whitespace
      self.gsub(/\s{2,}/, '').gsub("\n", '')
    end
  end

  it "should write deeply nested elements" do
    xml_out = library.to_xml.to_s
    xml_out.remove_whitespace.should == xml.remove_whitespace
  end

  it "should write two children of library: name and policy" do
    library.to_xml.children.map{|e| e.name }.should == ['name', 'policy']
  end

  it "should be re-parsable via .from_xml" do
    lib_reparsed = LibraryWithFines.from_xml(library.to_xml.to_s)
    lib_reparsed.name.should == library.name
    lib_reparsed.fines.should == library.fines
  end


end
