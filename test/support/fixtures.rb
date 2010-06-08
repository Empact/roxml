def fixture(name)
  File.read(fixture_path(name))
end

def xml_fixture(name)
  ROXML::XML.parse_file(fixture_path(name)).root
end

def fixture_path(name)
  "test/fixtures/#{name}.xml"
end
