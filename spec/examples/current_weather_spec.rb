require File.join(File.dirname(__FILE__), '../spec_helper')
require example('current_weather')

describe WeatherObservation do
  before do
    @observations = WeatherObservations.from_xml(xml_for('current_weather')).observations
  end

  it "should extract temperature" do
    @observations.each {|observation| observation.temperature.should > 0 }
  end

  it "should extract feels_like" do
    @observations.each {|observation| observation.feels_like.should > 0 }
  end

  describe "#current_condition" do
    it "should extract current_condition" do
      @observations.each {|observation| observation.current_condition.should_not be_empty }
    end

    it "should extract icon attribute" do
      @observations.each {|observation| observation.current_condition.should_not be_empty }
    end
  end
end