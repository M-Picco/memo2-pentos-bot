require 'telegram/bot'
require File.dirname(__FILE__) + '/../app/routes'

class BotClient
  def initialize(api_client, token = ENV['TELEGRAM_TOKEN'])
    @api_client = api_client
    @token = token
    @logger = Logger.new(STDOUT)
  end

  def start
    @logger.info "token is #{@token}"
    run_client do |bot|
      bot.listen { |message| handle_message(message, bot) }
    end
  end

  def run_once
    run_client do |bot|
      bot.fetch_updates { |message| handle_message(message, bot) }
    end
  end

  private

  def run_client(&block)
    Telegram::Bot::Client.run(@token, logger: @logger) { |bot| block.call bot }
  end

  def handle_message(message, bot)
    @logger.debug "@#{message.from.username}: #{message.inspect}"

    routes = Routes.new(@api_client)
    routes.handle(bot, message)
  end
end
