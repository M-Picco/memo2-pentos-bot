require File.dirname(__FILE__) + '/../lib/routing'

# rubocop:disable Metrics/ClassLength
class Routes
  include Routing

  def initialize(api_client)
    @api_client = api_client
    @logger = Logger.new(STDOUT)
  end

  on_message '/start' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: "Bienvenido al sistema de pedidos LaNona! \nPara registrarse ingresá /registracion {tu_domicilio},{tu_telefono}")
  end

  on_message '/stop' do |bot, message|
    bot.api.send_message(chat_id: message.chat.id, text: 'Gracias por usar el sistema de pedidos LaNona!')
  end

  on_message_pattern %r{\/registracion (?<dom>.*),(?<tel>.*)} do |bot, message, args|
    user = message.from.username || ''

    begin
      @api_client.register(user, args['dom'].strip, args['tel'].strip)

      bot.api.send_message(chat_id: message.chat.id, text: 'Registración exitosa')
    rescue StandardError => e
      @logger.debug e.backtrace

      text = "Registración fallida: #{e}"
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  on_message_pattern %r{\/registracion (?<text>.*)} do |bot, message, _args|
    bot.api.send_message(chat_id: message.chat.id, text: 'Registración fallida: Formato inválido (separar dirección y teléfono con ,)')
  end

  on_message_pattern %r{\/pedido (?<menu>.*)} do |bot, message, args|
    user = message.from.username || ''

    begin
      order_id = @api_client.order(user, args['menu'])
      bot.api.send_message(chat_id: message.chat.id, text: "Su pedido ha sido recibido, su número es: #{order_id}")
    rescue StandardError => e
      @logger.debug e.backtrace

      text = "Pedido fallido: #{e}"
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  on_message_pattern %r{\/estado (?<id_pedido>.*)} do |bot, message, args|
    user = message.from.username || ''

    begin
      status = @api_client.order_status(user, args['id_pedido'].strip.to_i)
      bot.api.send_message(chat_id: message.chat.id, text: "Su pedido #{args['id_pedido']} #{status}")
    rescue StandardError => e
      @logger.debug e.backtrace

      text = "Consulta fallida: #{e}"
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  on_message_pattern %r{\/calificar (?<id_pedido>.*) (?<calificacion>.*)} do |bot, message, args|
    user = message.from.username || ''

    begin
      @api_client.order_rate(user, args['id_pedido'].strip.to_i, args['calificacion'].strip.to_i)
      bot.api.send_message(chat_id: message.chat.id, text: "Su pedido #{args['id_pedido']} ha sido calificado exitosamente")
    rescue StandardError => e
      @logger.debug e.backtrace

      bot.api.send_message(chat_id: message.chat.id, text: e.message)
    end
  end

  on_message_pattern %r{\/cancelar (?<id_pedido>.*)} do |bot, message, args|
    user = message.from.username || ''

    begin
      @api_client.order_cancel(user, args['id_pedido'].strip.to_i)
      bot.api.send_message(chat_id: message.chat.id, text: 'Pedido cancelado con éxito')
    rescue StandardError => e
      @logger.debug e.backtrace

      bot.api.send_message(chat_id: message.chat.id, text: e.message)
    end
  end

  on_message '/historico' do |bot, message|
    user = message.from.username || ''

    begin
      historical_orders = @api_client.historical_orders(user)
      text = historical_message(historical_orders)
      bot.api.send_message(chat_id: message.chat.id, text: "Historial de pedidos:\n#{text}")
    rescue StandardError => e
      @logger.debug e.backtrace
      bot.api.send_message(chat_id: message.chat.id, text: e.message)
    end
  end

  on_message_pattern %r{\/estimado (?<id_pedido>.*)} do |bot, message, args|
    user = message.from.username || ''

    begin
      estimated_time = @api_client.estimated_time(user, args['id_pedido'].strip.to_i)
      bot.api.send_message(chat_id: message.chat.id, text: "Tiempo estimado: #{estimated_time}")
    rescue StandardError => e
      @logger.debug e.backtrace

      text = "Consulta fallida: #{e}"
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  def historical_message(orders_message)
    text = ''
    orders_message.each do |order_information|
      text += "====================\n" + order_information
    end

    text
  end

  default do |bot, message|
    help_message = "Comando no reconocido. Estos son los comandos disponibles\n
    - /registracion {dirección},{teléfono}\n
    - /pedido {tipo_menu}\n
    Pedidos disponibles: menu_individual, menu_pareja y menu_familiar\n
    -/estado {nro_pedido}\n
    - /estado {nro_pedido}\n
    - /calificar {nro_pedido} {calificación}\n
    - /cancelar {nro_pedido}\n
    - /historico"

    bot.api.send_message(chat_id: message.chat.id, text: help_message)
  end
end
# rubocop:enable Metrics/ClassLength
