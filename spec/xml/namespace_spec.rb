require 'spec/spec_helper.rb'

describe ROXML, "with namespaces" do
  context "with a default namespace" do
    class NamespaceyObject
      include ROXML
      xml_namespace :default

      xml_reader :default_namespace_with_namespace_false, :namespace => false
      xml_reader :default_and_explicit_namespace, :namespace => 'explicit'
      xml_reader :default_namespace_with_namespaceless_from, :from => 'with_namespaceless_from'
      xml_reader :default_namespace_with_namespaceless_from_and_explicit_namespace, :from => 'with_namespaceless_from', :namespace => 'explicit'
      xml_reader :default_namespace_with_namespaceless_from_and_namespace_false, :from => 'with_namespaceless_from', :namespace => false
      xml_reader :default_namespace_with_namespacey_from, :from => 'namespacy:with_namespacy_from'
      
      xml_reader :different_namespace, :from => 'different:namespace'
      xml_reader :namspace, :namespace => 'yet_another'
      xml_reader :no_namespace, :from => 'no_namespace', :namespace => false
    end

    before do
      @instance = NamespaceyObject.from_xml(%{
        <aws:book xmlns:aws="http://www.aws.com/aws" xmlns:different="http://www.aws.com/different">
          <aws:default_namespace>default_value</aws:default_namespace>
          <different:namespace>different_value</different:namespace>
          
          <namespacey:with_namespacey_from>namespacey node</namespacey:with_namespacey_from>
          <explicit:with_namespaceless_from>explicit namespace node</explicit:with_namespaceless_from>
          <with_namespaceless_from>namespaceless node</with_namespaceless_from>
          <default:with_namespaceless_from>default namespace node</default:with_namespaceless_from>
          <explicit:default_and_explicit_namespace>explicit namespace node</explicit:default_and_explicit_namespace>
          <default_namespace_with_namespace_false>namespaceless node</default_namespace_with_namespace_false>
        </aws:book>
      })
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

      context "and an explicit :namespace" do
        it "should raise" do
          xml_reader :default_namespace_with_namespacey_from_and_explicit_namespace, :from => 'namespacy:with_namespacy_from', :namespace => 'explicit'
        end
      end

      context "and :namespace => false" do
        it "should raise" do
          xml_reader :default_namespace_with_namespacey_from_and_namespace_false, :from => 'namespacy:with_namespacy_from', :namespace => false
        end
      end
    end
  end

  context "without a default namespace" do
    context "with an explicit :namespace" do
      it "should use the explicit namespace"
    end

    context "with a namespace-less :from" do
      it "should find the namespace-less node"
    
      context "and an explicit :namespace" do
        it "should use the explicit namespace"
      end
    end

    context "with a namespacey :from" do
      it "should use the :from namespace"

      context "and an explicit :namespace" do
        it "should raise"
      end
    end
  end
end
