require File.dirname(__FILE__) + '/../lib/routing'

class Routes
  include Routing

  def initialize(api_client)
    @api_client = api_client
  end

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Bienvenido al sistema de pedidos LaNona! \nPara registrarse ingresá /registracion {tu_domicilio},{tu_telefono}")
  end

  on_message '/stop' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Gracias por usar el sistema de pedidos LaNona!')
  end

  on_message_pattern %r{\/registracion (?<dom>.*),(?<tel>.*)} do |bot, message, args|
    user = message.from.username

    begin
      @api_client.register(user, args['dom'], args['tel'])

      bot.api.send_message(chat_id: message.chat.id, text: 'registracion exitosa')
    rescue StandardError => e
      text = "registracion fallida, #{e}"
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  on_message_pattern %r{\/registracion (?<text>.*)} do |bot, message, _args|
    bot.api.send_message(chat_id: message.chat.id, text: 'registracion fallida, formato invalido (separar direccion y telefono con ,)')
  end

  default do |bot, message|
    help_message = "Comando no reconocido. Estos son los comandos disponibles\n - /registracion {direccion},{telefono}"

    bot.api.send_message(chat_id: message.chat.id, text: help_message)
  end
end
