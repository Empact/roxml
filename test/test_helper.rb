require "lib/roxml"
require "test/unit"
require 'test/mocks'

def fixture(name)
  File.read("test/fixtures/#{name.to_s}.xml")
end