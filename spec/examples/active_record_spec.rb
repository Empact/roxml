require 'fileutils'
require_relative './../spec_helper'
require_relative './../../examples/rails'

describe ROXML, "under ActiveRecord" do
  before do
    @route = Route.from_xml(xml_for('active_record'))
  end

  before(:all) do
    FileUtils.rm(DB_PATH) if File.exists?(DB_PATH)
  end

  it "should be parsed" do
    @route.should_not == nil
    @route.should be_an_instance_of(Route)
  end

  describe "xml attributes" do
    it "should extract xml attributes" do
      @route.totalHg.should == "640"
      @route.lonlatx.should == "357865"
      @route.lonlaty.should == "271635"
      @route.grcenter.should == "SH 71635 57865"
      @route.totalMins.should == "235.75000000000003"
      @route.totalDist.should == "11185.321521477119"
    end
  end

  describe "xml sub-objects" do
    it "should extract xml sub-objects" do
      @route.should have(6).waypoints
      @route.waypoints.each {|waypoint| waypoint.should be_an_instance_of(Waypoint)}
    end
    it "should be usable as a ActiveRecord object" do
      Waypoint.count.should == 0
      @route.save!
      Waypoint.count.should == 6
    end
  end
end