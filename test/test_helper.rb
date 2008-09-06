require "lib/roxml"
require "test/unit"
require 'test/mocks'
require 'test/mocks/dictionaries'

def fixture(name)
  File.read("test/fixtures/#{name.to_s}.xml")
end