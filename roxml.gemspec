Gem::Specification.new do |s|
  s.name = "roxml"
  s.summary = "Ruby Object to XML mapping library"
  s.version = "1.2"
  s.homepage = "http://roxml.rubyforge.org"
  s.platform = Gem::Platform::RUBY
  s.author = "Zak Mandhro"
  s.email = "mandhro@yahoo.com"
  s.rubyforge_project = 'roxml'
  s.files = [
    'README.rdoc',
    'MIT-LICENSE',
    'Rakefile',
    'roxml.gemspec',
    'lib/roxml.rb',
    'lib/roxml/string.rb',
    'lib/roxml/xml.rb',
    'test/fixtures/book_malformed.xml',
    'test/fixtures/book_pair.xml',
    'test/fixtures/book_text_with_attribute.xml',
    'test/fixtures/book_valid.xml',
    'test/fixtures/book_with_authors.xml',
    'test/fixtures/book_with_contributions.xml',
    'test/fixtures/book_with_publisher.xml',
    'test/fixtures/library.xml',
    'test/fixtures/person.xml',
    'test/mocks.rb',
    'test/test_helper.rb',
    'test/unit/roxml_test.rb',
    'test/unit/string_test.rb',
    'test/unit/xml_name_test.rb',
    'test/unit/xml_text_test.rb',
    'test/unit/xml_object_test.rb',
    'test/unit/xml_attribute_test.rb']
  s.requirements << 'none'
  s.require_path = 'lib'
  s.test_files = [
    'test/unit/roxml_test.rb',
    'test/unit/string_test.rb',
    'test/unit/xml_text_test.rb',
    'test/unit/xml_object_test.rb',
    'test/unit/xml_name_test.rb',
    'test/unit/xml_attribute_test.rb']
  s.has_rdoc = true
  s.description = <<EOF
ROXML is a Ruby library designed to make it easier for Ruby developers to work with XML.
Using simple annotations, it enables Ruby classes to be mapped to XML. ROXML takes care
of the marshalling and unmarshalling of mapped attributes so that developers can focus on
building first-class Ruby classes. As a result, ROXML simplifies the development of
RESTful applications, Web Services, and XML-RPC.
EOF
end
