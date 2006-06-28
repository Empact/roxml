module FixtureHelper
  def fixture(name)
    File.read("test/fixtures/#{name.to_s}.xml")
  end
end