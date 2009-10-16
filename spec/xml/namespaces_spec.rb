require 'spec/spec_helper.rb'

describe ROXML, "#xml_namespaces" do
  class Tires
     include ROXML

     xml_namespaces \
       :bobsbike => 'http://bobsbikes.example.com',
       :alicesauto => 'http://alicesautosupply.example.com/'

     xml_reader :bike_tires, :as => [], :from => '@name', :in => 'bobsbike:tire'
     xml_reader :car_tires, :as => [], :from => '@name', :in => 'alicesauto:tire'
   end

  before do
     @xml = %{
       <?xml version="1.0"?>
       <inventory xmlns="http://alicesautosupply.example.com/" xmlns:bike="http://bobsbikes.example.com">
        <tire name="super slick racing tire" />
        <tire name="all weather tire" />
        <bike:tire name="skinny street" />
       </inventory>
     }
  end
  
  it "should remap default namespaces" do
    Tires.from_xml(@xml).car_tires.should =~ ['super slick racing tire', 'all weather tire']
  end

  it "should remap prefix namespaces" do
    Tires.from_xml(@xml).bike_tires.should == ['skinny street']
  end
end