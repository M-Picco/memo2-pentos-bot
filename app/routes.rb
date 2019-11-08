require File.dirname(__FILE__) + '/../lib/routing'

class Routes
  include Routing

  def initialize(api_client)
    @api_client = api_client
  end

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Bienvenido al sistema de pedidos LaNona! \nPara registrarse ingresá tu domicilio y teléfono con los comandos /domicilio y /telefono")
  end

  on_message_pattern %r{\/register (?<dom>.*),(?<tel>.*)} do |bot, message, args|
    user = message.from.username

    begin
      @api_client.register(user, args['dom'], args['tel'])

      bot.api.send_message(chat_id: message.chat.id, text: 'registracion exitosa')
    rescue StandardError => e
      text = "registracion fallida, #{e}"
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  on_message_pattern %r{\/register (?<text>.*)} do |bot, message, _args|
    bot.api.send_message(chat_id: message.chat.id, text: 'registracion fallida, formato invalido (separar direccion y telefono con ,)')
  end
end
