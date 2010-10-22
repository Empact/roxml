require_relative './../spec_helper'
require_relative './../../examples/current_weather'

describe Weather do
  before do
    @weather = Weather.from_xml(xml_for('current_weather'))
  end

  it "should extract observations" do
    @weather.observation.should be_an_instance_of(WeatherObservation)
  end
end

describe WeatherObservation do
  before do
    @observation = Weather.from_xml(xml_for('current_weather')).observation
  end

  it "should extract temperature" do
    @observation.temperature.should > 0
  end

  it "should extract feels_like" do
    @observation.feels_like.should > 0
  end

  describe "#current_condition" do
    it "should extract current_condition" do
      @observation.current_condition.should_not be_empty
    end

    it "should extract icon attribute" do
      pending "need to think options through for HappyMapper-style :attributes extensions"
      @observation.current_condition.icon.should_not be_empty
    end
  end
end