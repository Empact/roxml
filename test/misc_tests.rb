require "lib/roxml"
require "test/unit"
require "test/fixture_helper"
require "test/mocks/mocks"

class MiscTest < Test::Unit::TestCase
  include FixtureHelper
  
  # Verify that an exception is thrown when two accessors have the same
  # name in a ROXML class.
  def test_duplicate_accessor
    begin
      klass = Class.new do
        include ROXML
        
        xml_attribute :id
        xml_text :id
      end   
      raise "Defining a class with multiple accessors with same name should fail."
    rescue
      # Ok we should fail.
    end
  end
end