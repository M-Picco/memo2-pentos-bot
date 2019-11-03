require File.dirname(__FILE__) + '/../lib/routing'

class Routes
  include Routing

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Hola, #{message.from.first_name}")
  end

  on_message '/stop' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Chau, #{message.from.username}")
  end

  default do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Mmm no entendi, Me repetis la pregunta?')
  end
end
