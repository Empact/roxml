#!/usr/bin/env ruby

# Copyright (c) 2006 by Zak Mandhro
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial 
# portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO 
# EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rake'
require 'rake/tasklib'

module Rake
  class RailsPluginPackageTask < TaskLib
    attr_accessor :name
    attr_accessor :version
    # Directory used to store the package files (default is 'pkg/rails_plugin').
    attr_accessor :package_dir
    # Files to be stored in the package
    attr_accessor :package_files
    # Files to go into the root of the plug-in folder (e.g. init.rb)
    attr_accessor :plugin_files
    # Homepage for more information
    attr_accessor :extra_links
    # Verbose [true | false]
    attr_accessor :verbose

    # Create a package task
    def initialize(name=nil, version=nil)
      init(name, version)
      yield self if block_given?
      define unless name.nil?
    end

    # Init without yield self and define
    def init(name, version)
      @name = name
      @version = version
      @extra_links = nil
      @package_files = Rake::FileList.new
      @plugin_files = Rake::FileList.new
      @package_dir = 'pkg/rails_plugin'
      @folders = {}
      @verbose = false
    end
    
    def add_file(filename)
      dir = File.dirname(filename).gsub("#{@dest}",".")
      fn = File.basename(filename)
      folder = @folders[dir] || @folders[dir]=[]
      folder << fn
    end

    def add_folder(folder_name)
      dir = File.dirname(folder_name).gsub("#{@dest}",".")
      fn = File.basename(folder_name) + "/"
      folder = @folders[dir] || @folders[dir]=[]
      folder << fn
    end
    
    def define
      desc "Create Ruby on Rails plug-in package"
      task :rails_plugin do
        @dest = "#@package_dir/#@name"
        makedirs(@dest,:verbose=>false)
        @plugin_files.each do |fn|
          cp(fn, @dest,:verbose=>false)
          add_file(File.basename(fn))
        end
        
        @package_files.each do |fn|
          f = File.join(@dest, fn)
          fdir = File.dirname(f)
          unless File.exist?(fdir)
            mkdir_p(fdir,:verbose=>false)
            add_folder("#{fdir}/")
          end
          if File.directory?(fn)
            mkdir_p(f,:verbose=>false)
          else
            cp(fn, f, :verbose=>false)
            add_file(fn)
          end
        end
        
        generate_index_files()
      end
    end

    def generate_index_files
      @folders.each do |folder, files|
        puts " + Publishing #{@dest}/#{folder}/index.html" if @verbose
        File.open("#{@dest}/#{folder}/index.html", "w") do |index|
          title = "Rails Plug-in for #@name #@version"
          index.write("<html><head><title>#{title}</title></head>\n")
          index.write("<body>\n")
          index.write("<h2>#{title}</h2>\n")
          extra_links = create_extra_links()
          index.write("<p>#{extra_links}</p>\n") if extra_links          
          files.each { |fn|
            puts("  - Adding #{fn}") if @verbose
            index.write("&nbsp;&nbsp;<a href=\"#{fn}\">#{fn}</a><br/>\n")
          }
          index.write("<hr size=\"1\"/><p style=\"font-size: x-small\">Generated with RailsPluginPackageTask<p>")
          index.write("</body>\n")
          index.write("</html>\n")
        end
      end
    end
            
  private
    def create_extra_links
      return nil unless @extra_links
      x_links = ""
      if (@extra_links.class==Hash)
        @extra_links.each do |k,v|
          x_links << "<a href=\"#{v}\">#{k}</a>&nbsp;"
        end
      elsif (@extra_links.class==Array)
        @extra_links.each do |link|
          x_links << "<a href=\"#{link}\">#{link}</a>&nbsp;"
        end      
      else
        x_links = "<a href=\"#{@extra_links.to_s}\">#{@extra_links.to_s}</a>"
      end
      return x_links
    end
  end
end