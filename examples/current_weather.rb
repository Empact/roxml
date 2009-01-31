require File.join(File.dirname(__FILE__), '../lib/roxml')

class WeatherObservation
  include ROXML
  xml_convention :dasherize
  
  xml_name 'ob'
  xml_namespace 'aws'
  xml_reader :temperature, :as => Integer, :from => 'temp'
  xml_reader :feels_like, :as => Integer
  xml_reader :current_condition, :attributes => {:icon => String}
end

class WeatherObservations
  include ROXML
  xml_reader :observations, [WeatherObservation], :from => 'ob'
end

unless defined?(Spec)
  WeatherObeservations.from_xml(file_contents).each do |current_weather|
    puts "temperature: #{current_weather.temperature}"
    puts "feels_like: #{current_weather.feels_like}"
    puts "current_condition: #{current_weather.current_condition}"
    puts "current_condition.icon: #{current_weather.current_condition.icon}"
  end
end