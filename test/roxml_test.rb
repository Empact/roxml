$: << "#{File.dirname($0)}/../lib"

require 'roxml'
require 'test/unit'

class ROXMLTest < Test::Unit::TestCase
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

