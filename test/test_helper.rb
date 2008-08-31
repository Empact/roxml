require "lib/roxml"
require "test/unit"
require 'test/mocks'

module FixtureHelper
  def fixture(name)
    File.read("test/fixtures/#{name.to_s}.xml")
  end
end