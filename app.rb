require 'dotenv/load'
require File.dirname(__FILE__) + '/app/api_client'
require File.dirname(__FILE__) + '/app/bot_client'

api_url = ENV['API_URL'] || 'http://localhost:4567'
api_client = ApiClient.new(api_url)

bot_client = BotClient.new(api_client)
bot_client.start