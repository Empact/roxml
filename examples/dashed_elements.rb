#!/usr/bin/env ruby
require_relative './../spec/spec_helper'

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

unless defined?(Spec)
  commit = GitHub::Commit.from_xml(xml_for('dashed_elements'))
  puts commit.committed_date, commit.url, commit.id, ''
end