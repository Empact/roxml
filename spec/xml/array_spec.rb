require_relative './../spec_helper'

module ArraySpec
  class Book
    include ROXML
    xml_reader :id, :as => Integer
    xml_reader :title
  end

  class Store
    include ROXML
    xml_reader :books, :from => 'books', :as => [Book]
  end

  class MyXml
    include ROXML
    xml_reader :store, :as => Store
  end
end


describe ":as => []" do
  context "with plural from" do
    it "should accept the plural name as the name for each item" do
      ArraySpec::MyXml.from_xml(%(
      <myxml>
        <store>
          <books><id>1</id><title>first book</title></books>
          <books><id>2</id><title>second book</title></books>
          <books><id>3</id><title>third book</title></books>
        </store>
      </myxml>
      )).store.books.size.should == 3
    end
  end
end
