#!/usr/bin/env ruby
require_relative './../spec/spec_helper'
require 'sqlite3'
require 'active_record'

DB_PATH = 'spec/examples/rails.sqlite3'
ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => DB_PATH
)

class Waypoint < ActiveRecord::Base
  include ROXML

  belongs_to :route

  xml_attr :isLeg
  xml_attr :lonlatx
  xml_attr :lonlaty
  xml_attr :gridReference
  xml_attr :ascent
  xml_attr :descent
  xml_attr :distance
  xml_attr :bearing
  xml_attr :timemins
end

class Route < ActiveRecord::Base
  include ROXML

  has_many :waypoints

  xml_attr :title
  xml_attr :totalDist
  xml_attr :totalMins
  xml_attr :totalHg
  xml_attr :lonlatx
  xml_attr :lonlaty
  xml_attr :grcenter

  xml_attr :waypoints, :as => [Waypoint], :in => "waypoints"
end

# do a quick pseudo migration.  This should only get executed on the first run
if !Waypoint.table_exists?
  ActiveRecord::Base.connection.create_table(:waypoints) do |t|
    t.column :route_id, :integer
    t.column :isLeg, :string
    t.column :lonlatx, :string
    t.column :lonlaty, :string
    t.column :gridReference, :string
    t.column :ascent, :string
    t.column :descent, :string
    t.column :distance, :string
    t.column :bearing, :string
    t.column :timeMins, :string
  end
end

if !Route.table_exists?
  ActiveRecord::Base.connection.create_table(:routes) do |t|
    t.column :title, :string
    t.column :totalDist, :string
    t.column :totalMins, :string
    t.column :totalHg, :string
    t.column :lonlatx, :string
    t.column :lonlaty, :string
    t.column :grcenter, :string
  end
end