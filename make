#!/usr/bin/ruby
$: << "#{File.dirname($0)}/tools/rake"
begin
  require 'rake'
rescue LoadError
  require 'rubygems'
  require_gem 'rake'
end
RakeApp.new.run

