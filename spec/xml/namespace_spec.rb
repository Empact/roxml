require 'spec/spec_helper.rb'

describe ROXML, "with namespaces" do
  context "when an included namespace is not defined in the xml" do
    context "where the missing namespace is the default" do
      it "should raise"

      context "but the namespace is declared in the body" do
        it "should succeed"
      end
    end
    
    context "where the missing namespace is included in a namespacey from" do
      it "should raise"

      context "but the namespace is declared in the body" do
        it "should succeed"
      end
    end
    
    context "where the missing namespace is included in an explicit :namespace" do
      it "should raise"

      context "but the namespace is declared in the body" do
        it "should succeed"
      end
    end
  end
  
  describe "roxml namespacey declaration", :shared => true do
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

  describe "roxml namespacey declaration with default", :shared => true do
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
          @instance.default_namespace_with_namespaceless_from_and_namespace_false.should == 'explicit namespace node'
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
