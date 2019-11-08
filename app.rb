require 'dotenv/load'
require File.dirname(__FILE__) + '/app/bot_client'

api_client = ApiClient.new

BotClient.new.start(api_client)
