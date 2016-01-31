#!/usr/bin/env ruby
require 'twitter'
require 'yaml'
require 'json'
require 'base64'
require 'pry'

$config = YAML.load_file File.expand_path(".", "config.yml")

$LOAD_PATH.unshift File.expand_path './lib', File.dirname(__FILE__)

require 'fs'

# Twitter client configuration
$client = Twitter::REST::Client.new do |config|
  config.consumer_key = $config['twitter']['consumer_key']
  config.consumer_secret = $config['twitter']['consumer_secret']
  config.access_token = $config['twitter']['access_token']
  config.access_token_secret = $config['twitter']['access_token_secret']
end

# Twitter streaming configuration
$streamer = Twitter::Streaming::Client.new do |config|
  config.consumer_key = $config['twitter']['consumer_key']
  config.consumer_secret = $config['twitter']['consumer_secret']
  config.access_token = $config['twitter']['access_token']
  config.access_token_secret = $config['twitter']['access_token_secret']
end

# main process initialization
def main
  # Interactive shell using pry
  @shell ||= Thread.new do
    commands = Pry::CommandSet.new do

      command "send" do |file, name|
        DMFS.create_message("#{$config['folders']['upload']}/#{file}").each do |message|
          $client.create_direct_message name, message
        end
      end
      desc "send", "send a file to an user"
    end

    Pry.start binding, :commands => commands
  end

  # Twitter streaming to fetch incoming direct messages
  @twitter ||= Thread.new do
    loop do
      begin
        $streamer.user do |obj|
          case obj
          when Twitter::DirectMessage
            DMFS.receive_file_part(obj.id) if obj.text.start_with?("!!DMFS")
          end
        end
      rescue => e
        puts e.message
      end
      puts "Lost user stream connection"
      sleep 1
    end
  end

  @shell.join
  @twitter.join
end

main
