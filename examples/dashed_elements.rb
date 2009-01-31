require File.join(File.dirname(__FILE__), '../lib/roxml')

module GitHub
  class Commit
    include ROXML
    xml_convention :dasherize

    xml_reader :url
    xml_reader :tree
    xml_reader :message
    xml_reader :id
    xml_reader :committed_date, :as => Date
  end
end