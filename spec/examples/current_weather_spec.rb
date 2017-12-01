require 'spec_helper'
require_relative './../../examples/current_weather'

describe Weather do
  before do
    @weather = Weather.from_xml(xml_for('current_weather'))
  end

  it "should extract observations" do
    expect(@weather.observation).to be_an_instance_of(WeatherObservation)
  end
end

describe WeatherObservation do
  before do
    @observation = Weather.from_xml(xml_for('current_weather')).observation
  end

  it "should extract temperature" do
    expect(@observation.temperature).to be > 0
  end

  it "should extract feels_like" do
    expect(@observation.feels_like).to be > 0
  end

  describe "#current_condition" do
    it "should extract current_condition" do
      expect(@observation.current_condition).to_not be_empty
    end

    it "should extract icon attribute" do
      skip "need to think options through for HappyMapper-style :attributes extensions"
      expect(@observation.current_condition.icon).to_not be_empty
    end
  end
end