require 'spec_helper'
require_relative './../../examples/twitter'

describe Statuses do
  describe Status do
    before do
      @statuses = Statuses.from_xml(xml_for('twitter')).statuses
    end

    it "should extract text" do
      @statuses.each {|status| expect(status.text).to_not be_empty }
    end

    it "should extract source" do
      @statuses.each {|status| expect(status.source).to_not be_empty }
    end

    describe User do
      before do
        @users = @statuses.map(&:user)
      end

      it "should extract name" do
        @users.each {|user| expect(user.name).to eq("John Nunemaker") }
      end

      it "should extract screen_name" do
        @users.each {|user| expect(user.screen_name).to eq("jnunemaker") }
      end
    end
  end
end