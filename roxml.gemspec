# -*- encoding: utf-8 -*-
# stub: roxml 4.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "roxml"
  s.version = "4.2.0"

  s.required_ruby_version = ">= 3.0.0"
  s.required_rubygems_version = Gem::Requirement.new(">= 0")
  s.require_paths = ["lib"]
  s.authors = ["Ben Woosley", "Zak Mandhro", "Anders Engstrom", "Russ Olsen"]
  s.date = "2021-09-09"
  s.description = "ROXML is a Ruby library designed to make it easier for Ruby developers to work with XML.\nUsing simple annotations, it enables Ruby classes to be mapped to XML. ROXML takes care\nof the marshalling and unmarshalling of mapped attributes so that developers can focus on\nbuilding first-class Ruby classes. As a result, ROXML simplifies the development of\nRESTful applications, Web Services, and XML-RPC.\n"
  s.email = "ben.woosley@gmail.com"
  s.extra_rdoc_files = [
    "History.txt",
    "README.rdoc"
  ]
  s.files = [
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "History.txt",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "TODO",
    "VERSION",
    "examples/amazon.rb",
    "examples/current_weather.rb",
    "examples/dashed_elements.rb",
    "examples/library.rb",
    "examples/library_with_fines.rb",
    "examples/person.rb",
    "examples/posts.rb",
    "examples/rails.rb",
    "examples/search_query.rb",
    "examples/twitter.rb",
    "examples/xml/active_record.xml",
    "examples/xml/amazon.xml",
    "examples/xml/current_weather.xml",
    "examples/xml/dashed_elements.xml",
    "examples/xml/library_with_fines.xml",
    "examples/xml/person.xml",
    "examples/xml/posts.xml",
    "examples/xml/twitter.xml",
    "lib/roxml.rb",
    "lib/roxml/definition.rb",
    "lib/roxml/hash_definition.rb",
    "lib/roxml/utils.rb",
    "lib/roxml/xml.rb",
    "lib/roxml/xml/parsers/libxml.rb",
    "lib/roxml/xml/parsers/nokogiri.rb",
    "lib/roxml/xml/references.rb",
    "roxml.gemspec",
    "spec/definition_spec.rb",
    "spec/examples/active_record_spec.rb",
    "spec/examples/amazon_spec.rb",
    "spec/examples/current_weather_spec.rb",
    "spec/examples/dashed_elements_spec.rb",
    "spec/examples/library_spec.rb",
    "spec/examples/library_with_fines_spec.rb",
    "spec/examples/person_spec.rb",
    "spec/examples/post_spec.rb",
    "spec/examples/search_query_spec.rb",
    "spec/examples/twitter_spec.rb",
    "spec/reference_spec.rb",
    "spec/regression_spec.rb",
    "spec/roxml_spec.rb",
    "spec/shared_specs.rb",
    "spec/spec_helper.rb",
    "spec/support/libxml.rb",
    "spec/support/nokogiri.rb",
    "spec/xml/array_spec.rb",
    "spec/xml/attributes_spec.rb",
    "spec/xml/encoding_spec.rb",
    "spec/xml/namespace_spec.rb",
    "spec/xml/namespaces_spec.rb",
    "spec/xml/object_spec.rb",
    "spec/xml/parser_spec.rb",
    "spec/xml/text_spec.rb",
    "test/fixtures/book_malformed.xml",
    "test/fixtures/book_pair.xml",
    "test/fixtures/book_text_with_attribute.xml",
    "test/fixtures/book_valid.xml",
    "test/fixtures/book_with_authors.xml",
    "test/fixtures/book_with_contributions.xml",
    "test/fixtures/book_with_contributors.xml",
    "test/fixtures/book_with_contributors_attrs.xml",
    "test/fixtures/book_with_default_namespace.xml",
    "test/fixtures/book_with_depth.xml",
    "test/fixtures/book_with_octal_pages.xml",
    "test/fixtures/book_with_publisher.xml",
    "test/fixtures/book_with_wrapped_attr.xml",
    "test/fixtures/dictionary_of_attr_name_clashes.xml",
    "test/fixtures/dictionary_of_attrs.xml",
    "test/fixtures/dictionary_of_guarded_names.xml",
    "test/fixtures/dictionary_of_mixeds.xml",
    "test/fixtures/dictionary_of_name_clashes.xml",
    "test/fixtures/dictionary_of_names.xml",
    "test/fixtures/dictionary_of_texts.xml",
    "test/fixtures/library.xml",
    "test/fixtures/library_uppercase.xml",
    "test/fixtures/muffins.xml",
    "test/fixtures/nameless_ageless_youth.xml",
    "test/fixtures/node_with_attr_name_conflicts.xml",
    "test/fixtures/node_with_name_conflicts.xml",
    "test/fixtures/numerology.xml",
    "test/fixtures/person.xml",
    "test/fixtures/person_with_guarded_mothers.xml",
    "test/fixtures/person_with_mothers.xml",
    "test/mocks/dictionaries.rb",
    "test/mocks/mocks.rb",
    "test/support/fixtures.rb",
    "test/test_helper.rb",
    "test/unit/definition_test.rb",
    "test/unit/deprecations_test.rb",
    "test/unit/to_xml_test.rb",
    "test/unit/xml_attribute_test.rb",
    "test/unit/xml_block_test.rb",
    "test/unit/xml_bool_test.rb",
    "test/unit/xml_convention_test.rb",
    "test/unit/xml_hash_test.rb",
    "test/unit/xml_initialize_test.rb",
    "test/unit/xml_name_test.rb",
    "test/unit/xml_namespace_test.rb",
    "test/unit/xml_object_test.rb",
    "test/unit/xml_required_test.rb",
    "test/unit/xml_text_test.rb",
    "website/index.html"
  ]
  s.homepage = "https://github.com/Empact/roxml"
  s.rubygems_version = "3.2.15"
  s.summary = "Ruby Object to XML mapping library"

  s.add_runtime_dependency("concurrent-ruby", "~> 1.1")
  s.add_runtime_dependency("dry-core", ">= 0.4")
  s.add_runtime_dependency("nokogiri", ">= 1.3.3")
  s.add_runtime_dependency("rexml")
  s.add_runtime_dependency("time", "~> 0.3.0")

  s.add_development_dependency("rake", ">= 0.9")
  s.add_development_dependency("minitest")
  s.add_development_dependency("rspec", ">= 3.7.0")
  s.add_development_dependency("sqlite3", "~> 1.4")
  s.add_development_dependency("activerecord", ">= 4.0")
  s.add_development_dependency("equivalent-xml", ">= 0.6.0")
end

