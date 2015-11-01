#!/usr/bin/env ruby
require 'twitter'
require 'yaml'
require 'json'
require 'base64'
require 'pry'

CONFIG = YAML.load_file File.expand_path(".", "config.yml")

# Twitter client configuration
client = Twitter::REST::Client.new do |config|
  config.consumer_key = CONFIG['twitter']['consumer_key']
  config.consumer_secret = CONFIG['twitter']['consumer_secret']
  config.access_token = CONFIG'twitter']['access_token']
  config.access_token_secret = CONFIG['twitter']['access_token_secret']
end

# Twitter streaming configuration
streamer = Twitter::Streaming::Client.new do |config|
  config.consumer_key = CONFIG['twitter']['consumer_key']
  config.consumer_secret = CONFIG['twitter']['consumer_secret']
  config.access_token = CONFIG['twitter']['access_token']
  config.access_token_secret = CONFIG['twitter']['access_token_secret']
end

# main process initialization
def main
  # Interactive shell using pry
  @shell ||= Thread.new do
    binding.pry
  end

  # Twitter streaming to fetch incoming direct messages
  @twitter ||= Thread.new do

  end

  @shell.join
  @twitter.join
end

main