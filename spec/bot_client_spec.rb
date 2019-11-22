require 'spec_helper'
require 'web_mock'
# Uncomment to use VCR
require 'vcr_helper'

require File.dirname(__FILE__) + '/../app/bot_client'

def stub_get_updates(token, message_text, null_username = false)
  username = null_username ? nil : 'chambriento'

  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Cliente', "last_name": 'Hambriento', "username": username, "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Cliente', "last_name": 'Hambriento', "username": username, "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def stub_send_message(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Cliente', "last_name": 'Hambriento', "username": 'chambriento', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544', 'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

describe 'BotClient' do
  let(:token) { 'fake_token' }
  let(:api_client) { double }

  describe 'start' do
    it 'should get a /start message from an unregistered user and respond with a greeting' do
      stub_get_updates(token, '/start')
      stub_send_message(token, "Bienvenido al sistema de pedidos LaNona! \nPara registrarse ingresá /registracion {tu_domicilio},{tu_telefono}")

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'stop' do
    it 'should get a /stop message from an unregistered user and respond with a goodbye message' do
      stub_get_updates(token, '/stop')
      stub_send_message(token, 'Gracias por usar el sistema de pedidos LaNona!')

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'registration' do
    it 'should get a /registracion message with valid parameters and return a success message' do
      expect(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '4123-4123')

      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B,4123-4123')
      stub_send_message(token, 'Registración exitosa')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with only one parameter and return an invalid format message' do
      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B 4123-4123')
      stub_send_message(token, 'Registración fallida: Formato inválido (separar dirección y teléfono con ,)')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with invalid phone and return an error message' do
      allow(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '').and_raise('Teléfono inválido')

      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B,')
      stub_send_message(token, 'Registración fallida: Teléfono inválido')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with null username and return an error message' do
      expect(api_client).to receive(:register).with('', 'Cucha Cucha 1234 1 Piso B', '4123-4123').and_raise('Usuario inválido')

      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B,4123-4123', null_username: true)
      stub_send_message(token, 'Registración fallida: Usuario inválido')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with invalid address and return an error message' do
      allow(api_client).to receive(:register).with('chambriento', '', '4123-4123').and_raise('Dirección inválida')

      stub_get_updates(token, '/registracion ,4123-4123')
      stub_send_message(token, 'Registración fallida: Dirección inválida')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message for already registered client and return an error message' do
      allow(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '4123-4123').and_raise('Ya se encuentra registrado')

      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B,4123-4123')
      stub_send_message(token, 'Registración fallida: Ya se encuentra registrado')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with valid parameters, trim them and return a success message' do
      expect(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '4123-4123')

      stub_get_updates(token, '/registracion   Cucha Cucha 1234 1 Piso B  ,  4123-4123  ')
      stub_send_message(token, 'Registración exitosa')

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'order' do
    it 'should get a /pedido message from a registered user and respond with a success message' do
      expect(api_client).to receive(:order).with('chambriento', 'menu_pareja').and_return(1)

      stub_get_updates(token, '/pedido menu_pareja')
      stub_send_message(token, 'Su pedido ha sido recibido, su número es: 1')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    # rubocop:disable RSpec/ExampleLength
    it 'should get a /pedido message for an invalid menu from a registered user
        and respond with a success message' do
      expect(api_client).to receive(:order).with('chambriento', 'menu_ejecutivo').and_raise('Menú inválido')

      stub_get_updates(token, '/pedido menu_ejecutivo')
      stub_send_message(token, 'Pedido fallido: Menú inválido')

      app = BotClient.new(api_client, token)

      app.run_once
    end
    # rubocop:enable RSpec/ExampleLength

    it 'should get a /pedido message from an unregistered user and respond with a not registered message' do
      expect(api_client).to receive(:order).with('chambriento', 'menu_pareja').and_raise('Primero debes registrarte')

      stub_get_updates(token, '/pedido menu_pareja')
      stub_send_message(token, 'Pedido fallido: Primero debes registrarte')

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'status' do
    it 'should get a /estado message from a registered user and respond with a success message' do
      expect(api_client).to receive(:order_status).with('chambriento', 1).and_return('ha sido RECIBIDO')

      stub_get_updates(token, '/estado 1')
      stub_send_message(token, 'Su pedido 1 ha sido RECIBIDO')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /estado message from a registered user for an inexistent order and respond with an error message' do
      expect(api_client).to receive(:order_status).with('chambriento', 500).and_raise('El pedido indicado no existe')

      stub_get_updates(token, '/estado 500')
      stub_send_message(token, 'Consulta fallida: El pedido indicado no existe')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /estado message from an unregistered user and respond with a not registered message' do
      expect(api_client).to receive(:order_status).with('chambriento', 1).and_raise('Primero debes registrarte')

      stub_get_updates(token, '/estado 1')
      stub_send_message(token, 'Consulta fallida: Primero debes registrarte')

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'rate' do
    it 'should get a /calificar message from a registered user and respond with a success message' do
      expect(api_client).to receive(:order_rate).with('chambriento', 10, 4).and_return('Su pedido N ha sido calificado exitosamente')

      stub_get_updates(token, '/calificar 10 4')
      stub_send_message(token, 'Su pedido 10 ha sido calificado exitosamente')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    # rubocop:disable RSpec/ExampleLength:
    it 'should get a /calificar message from a registered user with an invalid rating
        and respond with an error message' do
      expect(api_client).to receive(:order_rate).with('chambriento', 10, -1)
                                                .and_raise("La calificación '-1' no es válida" \
                                                           ', ingresa un número entre 1 y 5')

      stub_get_updates(token, '/calificar 10 -1')
      stub_send_message(token, "La calificación '-1' no es válida, ingresa un número entre 1 y 5")

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /calificar message from a registered user for an order not in delivered state
        and respond with an error message' do
      expect(api_client).to receive(:order_rate).with('chambriento', 10, 4)
                                                .and_raise('El pedido solo puede calificarse una vez ENTREGADO')

      stub_get_updates(token, '/calificar 10 4')
      stub_send_message(token, 'El pedido solo puede calificarse una vez ENTREGADO')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /calificar message from an unregistered user and respond with a not registered message' do
      expect(api_client).to receive(:order_rate).with('chambriento', 10, 4).and_raise('Primero debes registrarte')

      stub_get_updates(token, '/calificar 10 4')
      stub_send_message(token, 'Primero debes registrarte')

      app = BotClient.new(api_client, token)

      app.run_once
    end
    # rubocop:enable RSpec/ExampleLength:
  end

  describe 'cancel' do
    it 'should get a /cancelar message from a registered user and respond with a success message' do
      expect(api_client).to receive(:order_cancel).with('chambriento', 10).and_return('Pedido cancelado con éxito')

      stub_get_updates(token, '/cancelar 10')
      stub_send_message(token, 'Pedido cancelado con éxito')

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'default message' do
    # rubocop:disable RSpec/ExampleLength:
    it 'responds with a help message when no valid commands supplied' do
      help_message = "Comando no reconocido. Estos son los comandos disponibles\n
    - /registracion {dirección},{teléfono}\n
    - /pedido {tipo_menu}\n
    Pedidos disponibles: menu_individual, menu_pareja y menu_familiar\n
    -/estado {nro_pedido}\n
    - /estado {nro_pedido}\n
    - /calificar {nro_pedido} {calificación}"

      stub_get_updates(token, '/un_comando_invalido')
      stub_send_message(token, help_message)

      app = BotClient.new(api_client, token)

      app.run_once
    end
    # rubocop:enable RSpec/ExampleLength:
  end
end
