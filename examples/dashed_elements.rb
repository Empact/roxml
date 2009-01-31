dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require File.join(dir, 'happymapper')

file_contents = File.read(dir + '/../spec/fixtures/commit.xml')

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

commit = GitHub::Commit.parse(file_contents)
puts commit.committed_date, commit.url, commit.id