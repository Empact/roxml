require File.join(File.dirname(__FILE__), '../lib/roxml')
require 'time'

class User
  include ROXML
  
  xml_reader :id, :as => Integer
  xml_reader :name
  xml_reader :screen_name
  xml_reader :location
  xml_reader :description
  xml_reader :profile_image_url
  xml_reader :url
  xml_reader :protected?
  xml_reader :followers_count, :as => Integer
end

class Status
  include ROXML
  
  xml_reader :id, :as => Integer
  xml_reader :text
	xml_reader :created_at, :as => Time
	xml_reader :source
	xml_reader :truncated?
	xml_reader :in_reply_to_status_id, :as => Integer
	xml_reader :in_reply_to_user_id, :as => Integer
	xml_reader :favorited?
	xml_reader :user, User
end

class Statuses
  include ROXML

  xml_reader :statuses, [Status]
end