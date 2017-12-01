require 'fileutils'
require 'spec_helper'
require_relative '../../examples/rails'

describe ROXML, "under ActiveRecord" do
  before do
    @route = Route.from_xml(xml_for('active_record'))
  end

  it "should be parsed" do
    expect(@route).to_not eq(nil)
    expect(@route).to be_an_instance_of(Route)
  end

  describe "xml attributes" do
    it "should extract xml attributes" do
      expect(@route.totalHg).to eq("640")
      expect(@route.lonlatx).to eq("357865")
      expect(@route.lonlaty).to eq("271635")
      expect(@route.grcenter).to eq("SH 71635 57865")
      expect(@route.totalMins).to eq("235.75000000000003")
      expect(@route.totalDist).to eq("11185.321521477119")
    end
  end

  describe "xml sub-objects" do
    it "should extract xml sub-objects" do
      expect(@route.waypoints.size).to eq(6)
      @route.waypoints.each {|waypoint| expect(waypoint).to be_an_instance_of(Waypoint)}
    end
    it "should be usable as a ActiveRecord object" do
      expect(Waypoint.count).to eq(0)
      @route.save!
      expect(Waypoint.count).to eq(6)
    end
  end
end
