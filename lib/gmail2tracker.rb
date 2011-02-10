require 'gmail'
require 'pivotal-tracker'
require 'gmail2tracker/gmail_ext'

module Gmail2tracker

  autoload :Message, 'gmail2tracker/message'
  autoload :TrackerStory, 'gmail2tracker/tracker_story'

  PivotalTracker::Client.token = ENV['TRACKER_API_KEY']
  PivotalTracker::Client.use_ssl = true

  def self.sync
    begin
      exceptions = Message.fetch_new
      TrackerStory.create_or_update exceptions
    ensure
      Message.disconnect
    end
  end

  def self.gmail_credentials
    credentials = [
      ENV["GMAIL_ACCOUNT"],
      ENV["GMAIL_PASS"]
    ]
    p credentials
  end
end

Gmail2tracker.sync
