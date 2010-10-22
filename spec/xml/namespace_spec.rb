require_relative './../spec_helper.rb'

describe ROXML, "with namespaces" do
  describe "for writing" do
    before do
      @xml = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<gronk:VApp name="My new vApp" status="1" href="https://vcloud.example.com/vapp/833" type="application/vnd.vmware.vcloud.vapp+xml" xmlns:vmw="http://foo.example.com" xmlns:gronk="http://gronk.example.com">
  <gronk:NetworkConfig name="Network 1">
    <vmw:FenceMode>allowInOut</vmw:FenceMode>
    <vmw:Dhcp>true</vmw:Dhcp>
    <gronk:errors>
      <gronk:error>OhNo!</gronk:error>
      <gronk:error>Another!</gronk:error>
    </gronk:errors>
  </gronk:NetworkConfig>
  <foo />
  <bar>
    gronk
  </bar>
</gronk:VApp>
EOS
    end

    class NetworkConfig
      include ROXML
      xml_namespace :gronk

      xml_name 'NetworkConfig'
      xml_reader    :name, :from => '@name'
      xml_reader    :errors, :as => []
      xml_accessor  :fence_mode, :from => 'vmw:FenceMode'
      xml_accessor  :dhcp?, :from => 'vmw:Dhcp'
    end

    class VApp
      include ROXML
      xml_namespace :gronk

      xml_name "VApp"
      xml_reader    :name,    :from => '@name'
      xml_reader    :status,  :from => '@status'
      xml_reader    :href,    :from => '@href'
      xml_reader    :type,    :from => '@type'
      xml_accessor  :foo,     :from => 'foo', :namespace => false
      xml_accessor  :bar,     :from => 'bar', :namespace => false
      xml_accessor  :network_configs, :as => [NetworkConfig], :namespace => :gronk
    end

    describe "#to_xml" do
      it "should reproduce the input xml" do
        output = ROXML::XML::Document.new
        output.root = VApp.from_xml(@xml).to_xml
        pending "Full namespace write support"
        output.should == ROXML::XML.parse_string(@xml)
      end
    end
  end

  shared_examples_for "roxml namespacey declaration" do
    context "with a namespacey :from" do
      context "and an explicit :namespace" do
        it "should raise" do
          proc do
            Class.new do
              include ROXML
              xml_reader :default_namespace_with_namespacey_from_and_explicit_namespace, :from => 'namespacey:with_namespacey_from', :namespace => 'explicit'
            end
          end.should raise_error(ROXML::ContradictoryNamespaces)
        end
      end

      context "and :namespace => false" do
        it "should raise" do
          proc do
            Class.new do
              include ROXML
              xml_reader :default_namespace_with_namespacey_from_and_namespace_false, :from => 'namespacey:with_namespacey_from', :namespace => false
            end
          end.should raise_error(ROXML::ContradictoryNamespaces)
        end
      end
    end
  end

  shared_examples_for "roxml namespacey declaration with default" do
    it_should_behave_like "roxml namespacey declaration"
    
    it "should use the default namespace" do
      @instance.default_namespace.should == 'default namespace node'
    end
    
    context "and :namespace => false" do
      it "should find the namespace-less node" do
        @instance.default_namespace_with_namespace_false.should == 'namespaceless node'
      end
    end

    context "with an explicit :namespace" do
      it "should use the explicit namespace" do
        @instance.default_and_explicit_namespace == 'explicit namespace node'
      end
    end

    context "with a namespace-less :from" do
      it "should use the default namespace" do
        @instance.default_namespace_with_namespaceless_from.should == 'default namespace node'
      end
      
      context "and :namespace => false" do
        it "should find the namespace-less node" do
          @instance.default_namespace_with_namespaceless_from_and_namespace_false.should == 'namespaceless node'
        end
      end

      context "and an explicit :namespace" do
        it "should use the explicit namespace" do
          @instance.default_namespace_with_namespaceless_from_and_explicit_namespace.should == 'explicit namespace node'
        end
      end
    end

    context "with a namespacey :from" do
      it "should use the :from namespace" do
        @instance.default_namespace_with_namespacey_from.should == 'namespacey node'
      end
    end
  end

  context "with a default namespace declared" do
    class DefaultNamespaceyObject
      include ROXML
      xml_namespace :default_declared

      xml_reader :default_namespace
      xml_reader :default_namespace_with_namespace_false, :namespace => false
      xml_reader :default_and_explicit_namespace, :namespace => 'explicit'
      xml_reader :default_namespace_with_namespaceless_from, :from => 'with_namespaceless_from'
      xml_reader :default_namespace_with_namespaceless_from_and_explicit_namespace, :from => 'with_namespaceless_from', :namespace => 'explicit'
      xml_reader :default_namespace_with_namespaceless_from_and_namespace_false, :from => 'with_namespaceless_from', :namespace => false
      xml_reader :default_namespace_with_namespacey_from, :from => 'namespacey:with_namespacey_from'

      # These are handled in the "roxml namespacey declaration" shared spec
      # xml_reader :default_namespace_with_namespacey_from_and_namespace_false, :from => 'namespacey:with_namespaceless_from', :namespace => false
      # xml_reader :default_namespace_with_namespacey_from_and_explicit_namespace, :from => 'namespacey:with_namespaceless_from', :namespace => 'explicit'
    end

    before do
      @instance = DefaultNamespaceyObject.from_xml(%{
        <book xmlns:namespacey="http://www.aws.com/aws" xmlns:default_declared="http://www.aws.com/default" xmlns:explicit="http://www.aws.com/different">
          <default_declared:default_namespace>default namespace node</default_declared:default_namespace>
          <namespacey:with_namespacey_from>namespacey node</namespacey:with_namespacey_from>
          <explicit:with_namespaceless_from>explicit namespace node</explicit:with_namespaceless_from>
          <with_namespaceless_from>namespaceless node</with_namespaceless_from>
          <default_declared:with_namespaceless_from>default namespace node</default_declared:with_namespaceless_from>
          <explicit:default_and_explicit_namespace>explicit namespace node</explicit:default_and_explicit_namespace>
          <default_namespace_with_namespace_false>namespaceless node</default_namespace_with_namespace_false>
        </book>
      })
    end
    
    it_should_behave_like "roxml namespacey declaration with default"
  end

  context "with a default namespace on the root node" do
    class XmlDefaultNamespaceyObject
      include ROXML
      xml_reader :default_namespace
      xml_reader :default_namespace_with_namespace_false, :namespace => false
      xml_reader :default_and_explicit_namespace, :namespace => 'explicit'
      xml_reader :default_namespace_with_namespaceless_from, :from => 'with_namespaceless_from'
      xml_reader :default_namespace_with_namespaceless_from_and_explicit_namespace, :from => 'with_namespaceless_from', :namespace => 'explicit'
      xml_reader :default_namespace_with_namespaceless_from_and_namespace_false, :from => 'with_namespaceless_from', :namespace => false
      xml_reader :default_namespace_with_namespacey_from, :from => 'namespacey:with_namespacey_from'

      # These are handled in the "roxml namespacey declaration" shared spec
      # xml_reader :default_namespace_with_namespacey_from_and_namespace_false, :from => 'namespacey:with_namespaceless_from', :namespace => false
      # xml_reader :default_namespace_with_namespacey_from_and_explicit_namespace, :from => 'namespacey:with_namespaceless_from', :namespace => 'explicit'
    end

    before do
      @instance = XmlDefaultNamespaceyObject.from_xml(%{
        <book xmlns="http://www.aws.com/xml_default" xmlns:namespacey="http://www.aws.com/aws" xmlns:default_declared="http://www.aws.com/default" xmlns:explicit="http://www.aws.com/different">
          <default_namespace>default namespace node</default_namespace>
          <namespacey:with_namespacey_from>namespacey node</namespacey:with_namespacey_from>
          <explicit:with_namespaceless_from>explicit namespace node</explicit:with_namespaceless_from>
          <with_namespaceless_from xmlns="">namespaceless node</with_namespaceless_from>
          <with_namespaceless_from>default namespace node</with_namespaceless_from>
          <explicit:default_and_explicit_namespace>explicit namespace node</explicit:default_and_explicit_namespace>
          <default_namespace_with_namespace_false xmlns="">namespaceless node</default_namespace_with_namespace_false>
        </book>
      })
    end

    it_should_behave_like "roxml namespacey declaration with default"
  end

  context "without a default namespace" do
    class NamespaceyObject
      include ROXML

      xml_reader :no_default_namespace
      xml_reader :no_default_namespace_with_namespace_false, :namespace => false
      xml_reader :no_default_but_an_explicit_namespace, :namespace => 'explicit'
      xml_reader :no_default_namespace_with_namespaceless_from, :from => 'with_namespaceless_from'
      xml_reader :no_default_namespace_with_namespaceless_from_and_explicit_namespace, :from => 'with_namespaceless_from', :namespace => 'explicit'
      xml_reader :no_default_namespace_with_namespaceless_from_and_namespace_false, :from => 'with_namespaceless_from', :namespace => false
      xml_reader :no_default_namespace_with_namespacey_from, :from => 'namespacey:with_namespacey_from'

      # These are handled in the "roxml namespacey declaration" shared spec
      # xml_reader :no_default_namespace_with_namespacey_from_and_explicit_namespace, :from => 'namespacey:with_namespacey_from', :namespace => 'explicit'
      # xml_reader :no_default_namespace_with_namespacey_from_and_namespace_false, :from => 'namespacey:with_namespacey_from', :namespace => false
    end

    before do
      @instance = NamespaceyObject.from_xml(%{
        <book xmlns:namespacey="http://www.aws.com/aws" xmlns:explicit="http://www.aws.com/different">
          <namespacey:with_namespacey_from>namespacey node</namespacey:with_namespacey_from>
          <explicit:with_namespaceless_from>explicit namespace node</explicit:with_namespaceless_from>
          <with_namespaceless_from>namespaceless node</with_namespaceless_from>
          <explicit:no_default_but_an_explicit_namespace>explicit namespace node</explicit:no_default_but_an_explicit_namespace>
          <no_default_namespace_with_namespace_false>namespaceless node</no_default_namespace_with_namespace_false>
          <no_default_namespace>namespaceless node</no_default_namespace>
        </book>
      })
    end
    
    it_should_behave_like "roxml namespacey declaration"

    it "should find the namespace-less node" do
      @instance.no_default_namespace.should == 'namespaceless node'
    end

    context "with :namespace => false" do
      it "should find the namespace-less node" do
        @instance.no_default_namespace_with_namespace_false.should == 'namespaceless node'
      end
    end

    context "with an explicit :namespace" do
      it "should use the explicit namespace" do
        @instance.no_default_but_an_explicit_namespace.should == 'explicit namespace node'
      end
    end

    context "with a namespace-less :from" do
      it "should find the namespace-less node" do
        @instance.no_default_namespace_with_namespaceless_from.should == 'namespaceless node'
      end
    
      context "and an explicit :namespace" do
        it "should use the explicit namespace" do
          @instance.no_default_namespace_with_namespaceless_from_and_explicit_namespace.should == 'explicit namespace node'
        end
      end

      context "with :namespace => false" do
        it "should find the namespace-less node" do
          @instance.no_default_namespace_with_namespaceless_from_and_namespace_false.should == 'namespaceless node'
        end
      end
    end

    context "with a namespacey :from" do
      it "should use the :from namespace" do
        @instance.no_default_namespace_with_namespacey_from.should == 'namespacey node'
      end
    end
  end
end
