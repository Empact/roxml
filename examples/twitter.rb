#!/usr/bin/env ruby
require_relative './../spec/spec_helper'
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
	xml_reader :created_at # This defaults to :as => DateTime, due to the '_at'
	xml_reader :source
	xml_reader :truncated?
	xml_reader :in_reply_to_status_id, :as => Integer
	xml_reader :in_reply_to_user_id, :as => Integer
	xml_reader :favorited?
	xml_reader :user, :as => User
end

class Statuses
  include ROXML

  xml_reader :statuses, :as => [Status]
end