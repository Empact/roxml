$: << "#{File.dirname($0)}/../lib"

require 'roxml'
require 'test/unit'

class Info
    include ROXML

    xml_attribute :title
    xml_text :description
    xml_text :tags, "tag", ROXML::TAG_CDATA|ROXML::TAG_ARRAY, "tags"

    def initialize
        yield self if block_given?
    end
end

class XTest
    include ROXML

    xml_text :text, false
    xml_name "ttt"
    xml_attribute :id, "ID" 
    xml_text :title, "TITLE"
    xml_text :description, "desc"
    xml_text :properties, "property", ROXML::TAG_CDATA, "properties"
    xml_object :info, Info 
    xml_object :infos, Info, ROXML::TAG_ARRAY, "infos"

    def initialize
        yield self if block_given?
    end

    def to_s
        "ID: #{@id}, TITLE: #{@title}, DESC: #{@description}, PROPS: #{@properties.join(':')}, TEXT: #{@text}"
    end

end

class RoXmlTest < Test::Unit::TestCase
    def test_it
        
        info = Info.new do |i|
            i.title = "An item"
            i.description = "alsd fhalsjhf l"
            i.tags = %w{tag1 tag2 tag3 tag4}
        end 

        infos = [
            Info.new do |i|
                i.title = "info_1"
                i.description = "desc_1"
                i.tags = %w{tag_1}
            end,
            Info.new do |i|
                i.title = "info_2"
                i.description = "desc_2"
                i.tags = %w{tag_1 tag_2}
            end,
            Info.new do |i|
                i.title = "info_3"
                i.description = "desc_3"
                i.tags = %w{tag_1 tag_2 tag_3}
            end
        ]

        t = XTest.new do |i|
            i.id = "12934876"
            i.title = "Item Title"
            i.description =<<-EOF
                A pretty long and intended description spanning
                several lines of input.
            EOF
            i.properties = %w{aaa bbb ccc ddd}
            i.info = info
            i.infos = infos
        end
        
        xml = ""
        t.to_xml.write(xml, 0)
        puts "========= TO_XML ========="
        puts xml
        puts "========= FROM_XML ======="
        puts XTest.parse(xml).inspect
        
    end
end

